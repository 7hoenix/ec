#
# Written with cthulahoops.
# The idea is to provide a single interface for quickly editing various configurations.
#

function ec {
  case "$1" in
      ''|help)
          echo "Basic Usage"
          echo "ec [command ...]"
          echo "   Edit configuration file(s)."
          echo "ec list"
          echo "   To show a list of all supported configuration files."
          echo "ec show [command ...]"
          echo "   To view the path to configuration file(s)."
          echo "ec reload [command ...]"
          echo "   To reload the configuration file(s)."
          echo "ec generate_template [ec_path]"
          echo "   Generate a template at the desired [ec_path]."
          ;;
      list)
          echo "Available configuration files:"
          for config in "${!ec_configs[@]}"
          do
            echo "    $config"
          done
          ;;
      show)
          shift
          for i in "$@"; do
            echo "$HOME/${ec_configs[$i]}"
          done
          ;;
      reload)
          shift
          for i in "$@"; do
            if [[ ${ec_reload_required[*]} =~ "$i" ]]; then
              source "$HOME/${ec_configs[$i]}"
            fi
          done
          ;;
      generate_template)
          set -o nounset
          ec_location="$2"
          echo "declare -A ec_configs"
          echo "ec_configs=("
          echo "  ['bash']=\".bashrc\""
          echo "  ['ec']=\"$ec_location\""
          echo ")"
          echo ""
          echo "# These are utilities that should be sourced into the shell."
          echo "ec_reload_required=(bash ec)"
          echo "source \"$ec_location\""
          set +o nounset
          ;;
      *)
          # This implementation assumes that the editor supports the -o flag for multiple files.
          # e.g. Vim.
          ec show "$@" | xargs $EDITOR -o
          ec reload "$@"
  esac
}
