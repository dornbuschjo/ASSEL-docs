# Cluster Info

seml https://github.com/TUM-DAML/seml
- Slurm Experiment Management Library
- developed by the chair and used by many

Marten Guides:
- https://gitlab.lrz.de/daml-group/cluster-guide
	- more in depth cluster info (you don't need to know all that - basic cluster usage is very easy)
- https://gitlab.lrz.de/martenlienen/students#other-resources
	- all kinds of technical info


## Recommended setup for cluster usage
add this to ``~/.bashrc``
```bash
export HUGGINGFACE_HUB_CACHE="/ceph/ssd/shared/hf_models"
export HF_HUB_CACHE="${HUGGINGFACE_HUB_CACHE}"

export HF_TOKEN_PATH="$HOME/.config/huggingface/token"

# simplify nvidia-smi
alias ismi='watch -d -n 0.5 nvidia-smi'

# simplify sb
alias sbi='sb dev start -p gpu_a100,gpu_h100,gpu_h200 -m 16G -c 8'
alias sbh='sb dev start -p gpu_h100,gpu_h200 -m 16G -c 8'
alias sba='sb dev start -p gpu_a100 -m 16G -c 8'
alias sbh100='sb dev start -p gpu_h100 -m 16G -c 8'
alias sbh200='sb dev start -p gpu_h200 -m 16G -c 8'
alias sblogin='sb dev login --vscode'
alias sque='watch -d -n 1 squeue -u $USER'
alias squei='watch -d -n 1 squeue -p gpu_a100,gpu_h100,gpu_h200'
alias squeh='watch -d -n 1 squeue -p gpu_h100,gpu_h200'
alias squea='watch -d -n 1 squeue -p gpu_a100'
alias squeh100='watch -d -n 1 squeue -p gpu_h100'
alias squeh200='watch -d -n 1 squeue -p gpu_h200'

# MongoDB settings
export MONGODB_USER='my_user'
export MONGODB_PASSWORD='my_pw'
export MONGODB_HOST='fs.daml.cit.tum.de:27017/'
```

### Register hf_token
1) **Store the token in a private per-user file**:
```bash
mkdir -p "$HF_TOKEN_PATH"
chmod 700 "$HF_TOKEN_PATH"
```

2) **One-time login** (writes token to the file):
	- paste your token when prompted and you may decline adding it to git credentials
```bash
hf auth login
chmod 600 "$HF_TOKEN_PATH"
```

3) **Quick verification** (Python):
```bash
python - <<'PY'
from huggingface_hub import constants, hf_hub_download
print("cache:", constants.HF_HUB_CACHE)
print("token file:", constants.HF_TOKEN_PATH)
print(hf_hub_download("gpt2", "config.json"))
PY
```