#!/bin/zsh

desired_formulae=(
    "argon2"
    "cmake"
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
    #"r"
    "sqlite"
    "yt-dlp"
)

desired_casks=(
    "1password"
    "basictex"
    "brave-browser"
    "coteditor"
    "cryptomator"
    "linearmouse"
    "iterm2"
    "nextcloud"
    "obsidian"
    "rectangle"
    "r"
    "rstudio"
    "spotify"
    "telegram"
    "visual-studio-code"
    "whatsapp"
    #"microsoft-office"
)

desired_fonts=(
    "Atkinson Hyperlegible Next"
    "JetBrains Mono"
    "Lexend Deca"
    "Merriweather"
    "New Computer Modern"
    "Noto Sans"
    "Noto Sans Mono"
    "Open Sans"
    "Noto Serif"
    "Roboto"
    "Roboto Mono"
    "Roboto Slab"
    "SF Pro"
    "SF Mono"
    "Source Code Pro"
    "Source Sans"
)

is_package_installed() {
    local type="$1"
    local package_name="$2"

    if [[ "$type" == "formula" ]]; then
        if brew list --version --formula "$package_name" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    elif [[ "$type" == "cask" ]]; then
        if brew list --version --cask "$package_name" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        echo "Invalid type: $type. Use 'formula' or 'cask'."
        return 1
    fi
}

is_font_installed() {
    local font_name="$1"
    if fc-list | grep -i "$font_name" > /dev/null; then
        return 0  # Font is installed
    else
        return 1  # Font is not installed
    fi
}

perform_install() {
    local type="$1"
    local package_name="$2"
    
    echo "🔄 Installing $type $package_name..."

    if [[ "$type" == "formula" ]]; then
        brew install --formula "$package_name"
    elif [[ "$type" == "cask" ]]; then
        brew install --cask "$package_name"
    else
        echo "Invalid type: $type. Use 'formula' or 'cask'."
        return 1
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

echo "\nChecking for software installations..."
printf "%-30s %-10s\n" "Software" "Status"
printf "%-30s %-10s\n" "--------" "------"

missing_formulae=()
missing_casks=()

for package in "${desired_formulae[@]}"; do
    if is_package_installed formula "$package"; then
        printf "%-30s %-10s\n" "$package" "✅ Installed"
    else
        printf "%-30s %-10s\n" "$package" "❌ Missing"
        missing_formulae+=("$package")
    fi
done

for package in "${desired_casks[@]}"; do
    if is_package_installed cask "$package"; then
        printf "%-30s %-10s\n" "$package" "✅ Installed"
    else
        printf "%-30s %-10s\n" "$package" "❌ Missing"
        missing_casks+=("$package")
    fi
done

if [ ${#missing_formulae[@]} -gt 0 ] || [ ${#missing_casks[@]} -gt 0 ]; then
    echo "\n💡 The following software is missing:"
    for package in "${missing_formulae[@]}"; do
        echo " - $package"
    done

    for package in "${missing_casks[@]}"; do
        echo " - $package"
    done

    echo "\n💿 Would you like to install all the missing packages at once? (y/N)"
    read -q "install_all_response?"
    echo

    if [[ "$install_all_response" =~ ^[Yy]$ ]]; then
        for package in "${missing_formulae[@]}"; do
            perform_install formula "$package"
        done

        for package in "${missing_casks[@]}"; do
            perform_install cask "$package"
        done
    fi
else
    echo "🎉 All software is already installed!"
fi

echo "\nChecking for font installations..."
printf "%-30s %-10s\n" "Font Name" "Status"
printf "%-30s %-10s\n" "---------" "------"

missing_fonts=()

for font in "${desired_fonts[@]}"; do
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
            perform_install cask font-"$(echo "$font" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
        done
    fi
else
    echo "🎉 All software is already installed!"
fi

echo "🎉 Setup complete!"
