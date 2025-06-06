#!/bin/zsh

# List of software to check and install via Homebrew
software_list=(
    "argon2"
    "exiftool"
    "ffmpeg"
    "gnupg"
    "imagemagick"
    "latexindent"
    "nmap"
    "openssl@3"
    "pandoc"
    "podman"
    "podman-compose"
    "python@3"
    "r"
    "sqlite"
    "yt-dlp"

    # Casks
    "basictex"
    "brave-browser"
    "coteditor"
    "cryptomator"
    "linearmouse"
    "iterm2"
    "nextcloud"
    "obsidian"
    "rectangle"
    "rstudio"
    "spotify"
    "visual-studio-code"
    "whatsapp"

    #"microsoft-office"
)

# List of fonts to install
fonts_list=(
    "Atkinson Hyperlegible Next"
    "JetBrains Mono"
    "Lexend Deca"
    "Merriweather"
    "New Computer Modern"
    "Noto Serif"
    "Noto Sans"
    "Noto Sans Mono"
    "Open Sans"
    "SF Pro"
    "SF Mono"
)

# Function to check if a package is installed via Homebrew
brew_installed() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0  # Command exists, preinstalled through other ways
    elif brew list --versions --cask "$1" >/dev/null 2>&1; then
        return 0  # Cask is installed
    elif brew list --versions "$1" >/dev/null 2>&1; then
        return 0  # Formula is installed
    else
        return 1  # Not installed
    fi
}

# Function to check if a font is installed
is_font_installed() {
    local font_name="$1"
    if fc-list | grep -i "$font_name" > /dev/null; then
        return 0  # Font is installed
    else
        return 1  # Font is not installed
    fi
}

perform_install() {
    local software="$1"
    
    echo "🔄 Installing $software..."

    if brew info --cask "$software" >/dev/null 2>&1; then
        brew install --cask "$software"
    else
        brew install "$software"
    fi
}

# Function to prompt for installation
prompt_install() {
    local software="$1"
    read -q "response?Do you want to install $software? (y/N) "
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        perform_install "$software"
    else
        echo "❌ $software will not be installed."
    fi
}

# Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🔄 Oh My Zsh is not installed. Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh is already installed."
fi

# Install Homebrew if not installed
if ! command -v brew >/dev/null 2>&1; then
    echo "🔄 Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew is already installed."
fi

# Check for software and display status
echo "\nChecking for software installations..."
printf "%-30s %-10s\n" "Software" "Status"
printf "%-30s %-10s\n" "--------" "------"

missing_software=()

for entry in "${software_list[@]}"; do
    IFS=":" read -r package <<< "$entry"
    if brew_installed "$package"; then
        printf "%-30s %-10s\n" "$package" "✅ Installed"
    else
        printf "%-30s %-10s\n" "$package" "❌ Missing"
        missing_software+=("$package")
    fi
done

# Prompt to install missing software
if [ ${#missing_software[@]} -gt 0 ]; then
    echo "\n💡 The following software is missing:"
    for software in "${missing_software[@]}"; do
        echo " - $software"
    done

    echo "\n💿 Would you like to install all the missing software at once? (y/N)"
    read -q "install_all_response?"
    echo

    if [[ "$install_all_response" =~ ^[Yy]$ ]]; then
        for software in "${missing_software[@]}"; do
            perform_install "$software"
        done
    else
        for software in "${missing_software[@]}"; do
            prompt_install "$software"
        done
    fi
else
    echo "🎉 All software is already installed!"
fi

# Check for software and display status
echo "\nChecking for font installations..."
printf "%-30s %-10s\n" "Font Name" "Status"
printf "%-30s %-10s\n" "--------" "------"

missing_fonts=()

for font in "${fonts_list[@]}"; do
    if is_font_installed "$font"; then
        printf "%-30s %-10s\n" "$font" "✅ Installed"
    else
        printf "%-30s %-10s\n" "$font" "❌ Missing"
        missing_fonts+=("$font")
    fi
done

if [ ${#missing_fonts[@]} -gt 0 ]; then
    echo "\n💡 The following fonts are missing:"
    for font in "${missing_fonts[@]}"; do
        echo " - $font"
    done

    echo "\n💿 Would you like to install all the missing fonts at once? (y/N)"
    read -q "install_all_response?"
    echo

    if [[ "$install_all_response" =~ ^[Yy]$ ]]; then
        for font in "${missing_fonts[@]}"; do
            perform_install font-"$(echo "$font" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
        done
    fi
else
    echo "🎉 All software is already installed!"
fi

echo "🎉 Setup complete!"
