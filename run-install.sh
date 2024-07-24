#!/bin/sh
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
        if command -v python3 > /dev/null 2>&1; then
            py=$(which python3)
            echo "Using python3"
        else
            echo "Please install Python 3 or 3.10 manually."
            exit 1
        fi
    fi

    $py -m venv .venv
    . .venv/bin/activate
    
    echo "Installing requirements..."
    pip install -r $requirements_file
}

prepare_install
