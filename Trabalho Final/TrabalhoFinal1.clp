; Definir o template sistema
(deftemplate sistema
    (slot tamanho (type SYMBOL) (allowed-values pequeno medio grande))
    (slot complexidade (type SYMBOL) (allowed-values baixa media alta))
    (slot escalabilidade (type SYMBOL) (allowed-values baixa media alta))
    (slot tamanho_equipe (type SYMBOL) (allowed-values pequena media grande))
    (slot necessidade_integracao (type SYMBOL) (allowed-values baixa media alta))
    (slot tipo_banco (type SYMBOL) (allowed-values SQL NoSQL))
    (slot stream_fila (type SYMBOL) (allowed-values sim nao))
    (slot tipo_arq (type SYMBOL) (allowed-values MS MVC))
)

(deftemplate sistema_entrada
    (slot nome_sistema (type STRING))
    (slot tamanho (type SYMBOL) (allowed-values pequeno medio grande))
    (slot complexidade (type SYMBOL) (allowed-values baixa media alta))
    (slot escalabilidade (type SYMBOL) (allowed-values baixa media alta))
    (slot tamanho_equipe (type SYMBOL) (allowed-values pequena media grande))
    (slot necessidade_integracao (type SYMBOL) (allowed-values baixa media alta))
    (slot tipo_banco (type SYMBOL) (allowed-values SQL NoSQL))
    (slot stream_fila (type SYMBOL) (allowed-values sim nao))
)

(deftemplate sistema_saida
    (slot nome_sistema (type STRING))
    (slot tipo_banco (type SYMBOL) (allowed-values SQL NoSQL))
    (slot stream_fila (type SYMBOL) (allowed-values sim nao))
    (slot tipo_arq (type SYMBOL) (allowed-values MS MVC))
)

; Função para ler o arquivo CSV e criar fatos
(defrule ler-csv
    (declare (salience 100)) ; Prioridade alta para garantir que o CSV seja lido primeiro
    =>
    (open "C:\\Users\\orck1\\OneDrive\\Documentos\\pos-senai\\P-s-IA_SENAI\\Trabalho Final\\regras.csv" arquivo "r")
    (bind ?linha (readline arquivo)) ; Ignora o cabeçalho, se houver
    (while (neq ?linha EOF)
        (bind ?linha (readline arquivo))
        (if (neq ?linha EOF) then
            (bind ?valores (explode$ ?linha)) ; Divide a linha em uma lista de valores
            (assert (sistema
                    (tamanho (nth$ 1 ?valores))
                    (complexidade (nth$ 2 ?valores))
                    (escalabilidade (nth$ 3 ?valores))
                    (tamanho_equipe (nth$ 4 ?valores))
                    (necessidade_integracao (nth$ 5 ?valores))
                    (tipo_banco (nth$ 6 ?valores))
                    (stream_fila (nth$ 7 ?valores))
                    (tipo_arq (nth$ 8 ?valores))
                ))
            )
    )
    (close arquivo)
    (assert (csv-lido))
)

; Função para coletar entrada do usuário
(deffunction coletar-entrada (?campo ?valores-permitidos)
   (printout t "Digite o valor para " ?campo " (" ?valores-permitidos "): ")
   (bind ?resposta (read))
   (while (not (member$ ?resposta ?valores-permitidos))
      (printout t "Valor inválido! Digite um valor válido para " ?campo " (" ?valores-permitidos "): ")
      (bind ?resposta (read))
   )
   ?resposta
)

; Função para coletar dados dos sistemas
(deffunction entrar-sistema ()
   (printout t "=== Sistema de Recomendação de Arquitetura ===" crlf)
   (printout t "Digite o valor para Nome do Sistema: ")
   (bind ?nome_sistema (read))
   (bind ?tamanho (coletar-entrada "tamanho do projeto" (create$ pequeno medio grande)))
   (bind ?complexidade (coletar-entrada "complexidade do projeto" (create$ baixa media alta)))
   (bind ?escalabilidade (coletar-entrada "necessidade de escalabilidade" (create$ baixa media alta)))
   (bind ?tamanho_equipe (coletar-entrada "tamanho da equipe" (create$ pequena media grande)))
   (bind ?necessidade_integracao (coletar-entrada "necessidade de integração" (create$ baixa media alta)))
   (assert (sistema_entrada
           (nome_sistema ?nome_sistema)    
           (tamanho ?tamanho)
           (complexidade ?complexidade)
           (escalabilidade ?escalabilidade)
           (tamanho_equipe ?tamanho_equipe)
           (necessidade_integracao ?necessidade_integracao)
       ))
)

; Regra para iniciar o sistema
(defrule iniciar-sistema
   (declare (salience 80))
   =>
   (bind ?entrada "")
   (while (neq ?entrada sair)
        (printout t "=== Selecinar Tipo de entrada de Dados :  ===" crlf)
        (printout t "=== 1 - para entrada manual  ===" crlf)
        (printout t "=== 2 - para leitura de arquivo  ===" crlf)


        (printout t "Digite 'sair' para encerrar ou pressione Enter para continuar: ")
        (system "cls")
        (bind ?entrada (read))
   )
   
)