#!/bin/sh
printf "\033]0;Installer\007"
clear
rm *.bat

prepare_install() {
   
    if [ -d ".venv" ]; then
        echo "Venv found. This implies Applio has been already installed or this is a broken install."
        echo "Removing existing virtual environment..."
        rm -rf .venv
    fi
    
    echo "Creating new venv..."
    
    requirements_file="requirements.txt"
    echo "Checking if python exists"
    
    if command -v python3.10 > /dev/null 2>&1; then
        py=$(which python3.10)
        echo "Using python3.10"
    else
        if python --version | grep -qE "3\.(7|8|9|10)\."; then
            py=$(which python)
            echo "Using python"
        else
            echo "Please install Python 3 or 3.10 manually."
            exit 1
        fi
    fi

    $py -m venv .venv
    . .venv/bin/activate
    python -m ensurepip
    pip3 install --upgrade pip
    echo
    echo "Installing Applio dependencies..."
    python -m pip install -r requirements.txt
    python -m pip uninstall torch torchvision torchaudio -y
    python -m pip install torch==2.1.1 torchvision==0.16.1 torchaudio==2.1.1 --index-url https://download.pytorch.org/whl/cu121
    finish
}

finish() {
    if [ -f "${requirements_file}" ]; then
        installed_packages=$(python -m pip freeze)
        while IFS= read -r package; do
            expr "${package}" : "^#.*" > /dev/null && continue
            package_name=$(echo "${package}" | sed 's/[<>=!].*//')
            if ! echo "${installed_packages}" | grep -q "${package_name}"; then
                echo "${package_name} not found. Attempting to install..."
                python -m pip install --upgrade "${package}"
            fi
        done < "${requirements_file}"
    else
        echo "${requirements_file} not found. Please ensure the requirements file with required packages exists."
        exit 1
    fi

    clear
    echo "Applio has been successfully downloaded. Running run-applio.sh..."

    chmod +x run-applio.sh
    ./run-applio.sh
    exit 0
}

if [ "$(uname)" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        brew install python@3.10
        export PYTORCH_ENABLE_MPS_FALLBACK=1
        export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
    fi
elif [ "$(uname)" != "Linux" ]; then
    echo "Unsupported operating system. Are you using Windows...?"
    echo "If yes, use the batch (.bat) file instead of this one!"
    exit 1
fi

prepare_install
