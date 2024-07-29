#!/bin/sh

export TERM=xterm

printf "\033]0;Installer\007"
clear
rm -f *.bat

prepare_install() {
    echo "Creating venv..."
    requirements_file="requirements.txt"
    echo "Checking if Python exists"
    
    if command -v python3.10 > /dev/null 2>&1; then
        py=$(which python3.10)
        echo "Using Python 3.10"
    elif command -v python3 > /dev/null 2>&1; then
        py=$(which python3)
        echo "Using Python 3"
    elif command -v python > /dev/null 2>&1 && python --version | grep -qE "3\.(7|8|9|10)\."; then
        py=$(which python)
        echo "Using Python"
    else
        echo "Python not found. Please install Python 3 or 3.10 manually."
        exit 1
    fi

    $py -m venv .venv
    . .venv/bin/activate
    python -m ensurepip
    pip install --upgrade pip
    
    export PYTORCH_ENABLE_MPS_FALLBACK=1
    export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0

    echo
    echo "Installing Applio dependencies..."
    python -m pip install -r requirements.txt

    
    python -m pip uninstall torch torchvision torchaudio -y
    python -m pip install torch==2.1.1 torchvision==0.16.1 torchaudio==2.1.1 --index-url https://download.pytorch.org/whl/cu121
    
    pip uninstall urllib3 requests -y
    pip install urllib3 requests

    finish
}

finish() {
    if [ -f "${requirements_file}" ]; then
        installed_packages=$(python -m pip freeze)
        while IFS= read -r package; do
           
            expr "${package}" : "^#.*" > /dev/null && continue
            if [ -n "$package" ]; then
                package_name=$(echo "${package}" | sed 's/[<>=!].*//')
                if ! echo "${installed_packages}" | grep -q "${package_name}"; then
                    echo "${package_name} not found. Attempting to install..."
                    python -m pip install --upgrade "${package}"
                fi
            fi
        done < "${requirements_file}"
    else
        echo "${requirements_file} not found. Please ensure the requirements file with required packages exists."
        exit 1
    fi
    clear
    echo "Applio has been successfully downloaded. Running run-applio.sh now..."
    chmod +x ./run-applio.sh
    clear
    ./run-applio.sh | tee -a installation.log
    exit 0
}

if [ "$(uname)" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install python@3.10
elif [ "$(uname)" = "Linux" ]; then
    
    echo "Linux detected. Proceeding with Linux-specific instructions."
else
    echo "Unsupported operating system. Are you using Windows...?"
    echo "If yes, use the batch (.bat) file instead of this one!"
    exit 1
fi

prepare_install
