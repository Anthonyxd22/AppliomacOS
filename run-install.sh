#!/bin/sh

clear
rm *.bat

if [ -d ".venv" ]; then
    echo "Venv found. This implies Applio has been already installed or this is a broken install."
    echo "Removing existing virtual environment..."
    rm -rf .venv
fi

echo "Creating new venv..."

requirements_file="requirements.txt"
echo "Checking if python exists..."

if command -v python3.10 > /dev/null 2>&1; then
    py=$(which python3.10)
    echo "Using python3.10"
elif command -v python3.9 > /dev/null 2>&1; then
    py=$(which python3.9)
    echo "Using python3.9"
elif command -v python3 > /dev/null 2>&1; then
    py=$(which python3)
    echo "Using python3"
else
    echo "Please install Python 3.9 or 3.10 manually."
    exit 1
fi

$py -m venv .venv
. .venv/bin/activate

echo "Installing pip and dependencies..."

python -m ensurepip
pip install --upgrade pip

echo "Installing Applio dependencies..."
python -m pip install -r $requirements_file
python -m pip uninstall torch torchvision torchaudio -y
python -m pip install torch==2.1.1 torchvision==0.16.1 torchaudio==2.1.1 --index-url https://download.pytorch.org/whl/cu121

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
    echo "Applio has been successfully downloaded. Setting permissions for run-applio.sh..."
    chmod +x ./run-applio.sh
    echo "Running run-applio.sh now..."
    ./run-applio.sh
    exit 0
}

if [ "$(uname)" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        brew install python@3.10
    fi
elif [ "$(uname)" != "Linux" ]; then
    echo "Unsupported operating system. Are you using Windows...?"
    echo "If yes, use the batch (.bat) file instead of this one!"
    exit 1
fi

finish
