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
          echo
          ec list
          ;;
      list)
          [ -t 1 ] && echo "Available configuration files:"
          for config in "${!ec_configs[@]}"
          do
            echo "    $config"
          done
          ;;
      show)
          shift
          for i in "$@"; do
            echo "${ec_configs[$i]}"
          done
          ;;
      reload)
          shift
          for i in "$@"; do
            if [[ ${ec_reload_required[*]} =~ "$i" ]]; then
              source "${ec_configs[$i]}"
            fi
          done
          ;;
      generate_template)
          set -o nounset
          ec_location="$2"
          echo "declare -A ec_configs"
          echo "ec_configs=("
          echo "  ['bash']=\"$HOME/.bashrc\""
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

function _ec_complete {
  words="$(ec list)"
  if [ "${#COMP_WORDS[@]}" == 2 ]; then
    words="reload show list help $words"
  fi
  COMPREPLY=$(compgen -W "$words" "${COMP_WORDS[-1]}")
}
complete -F _ec_complete ec
