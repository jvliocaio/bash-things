#!/bin/bash

OLLAMA_API="http://localhost:11434/api/generate"
MODEL="llama3"
MAX_DIFF_LENGTH=4000
PROMPT_FILE="prompt.txt"

print_info() {
  echo -e "\033[1;34m$1\033[0m"
}
print_warn() {
  echo -e "\033[1;33m$1\033[0m"
}
print_error() {
  echo -e "\033[1;31m$1\033[0m"
}
print_success() {
  echo -e "\033[1;32m$1\033[0m"
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  print_error "Este diretório não é um repositório Git!"
  exit 1
fi

if [[ -z $(git status --porcelain) ]]; then
  print_warn "Nenhuma alteração detectada no repositório."
  exit 0
fi

print_info "\nAlterações detectadas:"
git status -s

read -p $'\nDeseja gerar uma mensagem de commit com IA? (s/n): ' confirm
if [[ "$confirm" != "s" ]]; then
  print_warn "Cancelado pelo usuário."
  exit 0
fi

git add .

DIFF=$(git --no-pager diff --cached | head -c $MAX_DIFF_LENGTH)

if [[ -z "$DIFF" ]]; then
  print_error "Nenhum diff detectado após git add. Nada para processar."
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  print_error "Arquivo de prompt não encontrado: $PROMPT_FILE"
  exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")
FINAL_PROMPT="$PROMPT"$'\n'"$DIFF"

print_info "\nGerando sugestão de mensagem de commit..."
RESPONSE=$(curl -s "$OLLAMA_API" -d "{
  \"model\": \"$MODEL\",
  \"prompt\": \"$(echo "$FINAL_PROMPT" | jq -Rs . | cut -c 2- | rev | cut -c 2- | rev)\",
  \"stream\": false
}" 2>/dev/null | jq -r '.response')

if [[ -z "$RESPONSE" ]]; then
  print_error "Falha ao obter resposta da API ou resposta vazia."
  exit 1
fi

COMMIT_MSG=$(echo "$RESPONSE" | sed 's/^"//;s/"$//')

print_info "\nSugestão de mensagem:"
echo -e "\n\"$COMMIT_MSG\"\n"

read -p "Deseja aplicar esta mensagem, commit e push? (s/n): " confirm_final
if [[ "$confirm_final" != "s" ]]; then
  print_warn "Operação cancelada."
  exit 0
fi

if git commit -m "$COMMIT_MSG"; then
  print_success "\nCommit realizado com sucesso."
  
  read -p "Deseja fazer push para o repositório remoto? (s/n): " do_push
  if [[ "$do_push" == "s" ]]; then
    if git push; then
      print_success "Push realizado com sucesso."
    else
      print_error "Erro ao executar push."
      exit 1
    fi
  else
    print_warn "Push não realizado."
  fi
else
  print_error "Erro ao executar commit."
  exit 1
fi