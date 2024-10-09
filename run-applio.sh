#!/bin/sh

# Set terminal type
export TERM=xterm-256color


printf "\033]0;Applio\007"

# Activate the virtual environment
. .venv/bin/activate


export PYTORCH_ENABLE_MPS_FALLBACK=1
export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0

# Clear the terminal
clear

# Run the application
python app.py --open
