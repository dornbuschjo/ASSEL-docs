# Python Packagemanagement - Pixi

tldr:
1. Pixi is a tool that unifies conda and pip package management with a lock file for reproducibility.
2. Use ``direnv`` for auto-activation of Pixi environments when entering a project directory.

Own words: Pixi unifies conda and pip with a lock file.
That means you can use the conde-forge to pull build packages, which can be really convenient, and still have the freedom to use pip ([[UV]] can not use conda). Also you have a lock file, which saves the exact locations and versions you have in your env, so if you have this, you can exactly reproduce the env.

## Toml - lock - env
- Toml (Manifest)
	- can be ``pixi.toml`` or ``pyproject.toml``
		- prefer ``pyproject.toml`` because you can save multiple settings for your project in there
	- this is kind of the recipe of packages you want to have - the *manifest*
	- you add stuff there with the ``pixi add numpy "pytorch>=2.6"`` or ``pixi add --pypi "transformers==4.56.2"``
		- note: this also updates the env and the lock! Pixi does not let the manifest and the env/lock get out of sync, so it als triggers a pixi install
			- you can however explicitly skip the install with ``pixi add python==3.11 --no-install``, which will not touch the env, but toml and lock
- lock
	- this saves the details of your exact env. With this a peer can recreate your exact env. pixi uses the toml to know what you want, builds the env and saves the details for reproducibility in the lock
- env
	- is saved in the project under ``.pixi``
    - can install stuff to then env with regular pip, but with the next sync trigger, pixi will make sure to keep the env in check with the lock and toml, so it will remove directly installed packages
- #### pixi philosophy: toml and lock should never be out of sync


## Create a new env
```bash
pixi init --format pyproject
```
- creates a ``pyproject.toml`` and the ``tool.pixi.workspace`` section, if it not already exists

- add a ``.envrc`` file for auto activation
```bash
cat > .envrc <<'EOF'
watch_file pixi.lock
eval "$(pixi shell-hook)"
EOF
```

- start with adding a python version and packages, which are per default garbed from conda forge
```bash
pixi add python==3.11 pip
```

- install torch
	- it is recommended to use conda-forge by simply ``pixi add``, but if you need pip for a specific version you might do this to extend the regular pypi with the pytorch index:
```toml
[tool.pixi.pypi-dependencies]
torch = "==2.7.1"
torchvision = "==0.22.1"
torchaudio = "==2.7.1"

[tool.pixi.pypi-options]
extra-index-urls = ["https://download.pytorch.org/whl/cu121"]
index-strategy = "unsafe-best-match"
```
## Create env from existing lock and toml
```bash
pixi install --frozen
```

## Basic usage
- ``pixi add`` to add packages to the manifest using conda-forge (triggers an install)
- ``pixi add --pypi`` to add packages to the manifest using pypi (triggers an install)
- ``pixi install`` to install the env based on the manifest and lock
- ``pixi remove`` to remove packages
- ``pixi shell`` to manually activate the env in the current shell (if you don't use direnv auto-activation)


## Pixi + direnv auto-activation in bash terminal

This sets up a workflow similar to conda auto-activation:

- When you `cd` into a project folder that contains a `.envrc`, **direnv** will run it (if it was previously allowed).
- If that `.envrc` activates a Pixi environment, your shell environment updates automatically (PATH, vars, etc.).
- When you `cd` out of the folder, **direnv restores the previous environment** (i.e., Pixi gets deactivated automatically).

The one-time trust step is `direnv allow`:
- You run it once per project (per `.envrc` *content*).
- If `.envrc` changes, direnv will require `direnv allow` again for safety.

#### What you’ll get
- Pixi environment auto-activates when you enter the repo
- Pixi environment auto-deactivates when you leave the repo
- Your terminal prompt shows the Pixi prefix (e.g. `(AAPL)`)
- direnv no longer prints the big `direnv: export +... ~PATH` diff line


#### One-time setup script (no sudo)

[setup_pixi_direnv.sh](setup_pixi_direnv.sh)

```bash
bash setup_pixi_direnv.sh
```
