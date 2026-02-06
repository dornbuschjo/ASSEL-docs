# Cluster Info

seml https://github.com/TUM-DAML/seml
- Slurm Experiment Management Library
- developed by the chair and used by many

Marten Guides:
- https://gitlab.lrz.de/daml-group/cluster-guide
	- more in depth cluster info (you don't need to know all that - basic cluster usage is very easy)
- https://gitlab.lrz.de/martenlienen/students#other-resources
	- all kinds of technical info


helpful bash commands
add it to ``~/.bashrc``
```bash
export HUGGINGFACE_TOKEN="my_token"
export HF_TOKEN="${HUGGINGFACE_TOKEN}"
export HF_API_TOKEN="${HUGGINGFACE_TOKEN}"
export HUGGINGFACE_HUB_CACHE="/ceph/ssd/shared/hf_models"

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