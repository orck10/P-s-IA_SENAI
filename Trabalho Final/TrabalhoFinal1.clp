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
)

(deftemplate sistema_saida
    (slot nome_sistema (type STRING))
    (slot tipo_banco (type SYMBOL) (allowed-values SQL NoSQL))
    (slot stream_fila (type SYMBOL) (allowed-values sim nao))
    (slot tipo_arq (type SYMBOL) (allowed-values MS MVC))
)

; Função para ler o arquivo CSV e criar fatos
(deffunction ler-csv ()
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
                )
            )
        )
    )
    (close arquivo)
)

(deffunction ler-teste ()
    (open "C:\\Users\\orck1\\OneDrive\\Documentos\\pos-senai\\P-s-IA_SENAI\\Trabalho Final\\teste.csv" arquivo "r")
    (bind ?linha (readline arquivo)) ; Ignora o cabeçalho, se houver
    (while (neq ?linha EOF)
        (bind ?linha (readline arquivo))
        (if (neq ?linha EOF) then
            (bind ?valores (explode$ ?linha)) ; Divide a linha em uma lista de valores
            (assert (sistema_entrada
                    (nome_sistema (nth$ 1 ?valores))
                    (tamanho (nth$ 2 ?valores))
                    (complexidade (nth$ 3 ?valores))
                    (escalabilidade (nth$ 4 ?valores))
                    (tamanho_equipe (nth$ 5 ?valores))
                    (necessidade_integracao (nth$ 6 ?valores))
                )
            )
        )
    )
    (close arquivo)
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
        )
    )
)

; Regra para iniciar o sistema
(defrule iniciar-sistema
   (declare (salience 80))
   =>
   (bind ?entrada "")
   (bind ?teste-lido FALSE)
   (ler-csv) ; Lê o arquivo CSV para carregar os dados
   (printout t "=== Bem-vindo ao Sistema de Recomendação de Arquitetura ===" crlf)
   (while (neq ?entrada 3)
        
        (printout t "=== Selecinar Tipo de entrada de Dados :  ===" crlf)
        (printout t "=== 1 - para entrada manual  ===" crlf)
        (printout t "=== 2 - para leitura de arquivo  ===" crlf)
        (printout t "=== 3 - para encerrar leitura do sistema ===" crlf)
        (bind ?entrada (read))
        (if (eq ?entrada 1) then
            (entrar-sistema) ; Coleta dados manualmente
        )
        (if (and (eq ?entrada 2) (eq ?teste-lido FALSE)) then
            (printout t "=== Lendo arquivo CSV ===" crlf)
            (ler-teste) ; Lê o arquivo CSV para carregar os dados
            (printout t "=== Dados lidos com sucesso! ===" crlf)
            (bind ?teste-lido TRUE) ; Marca que o teste foi lido
        )
        (if (eq ?entrada 3) then
            (printout t "Encerrando leitura.." crlf)
            (return)
        )
        (if (or (eq ?entrada 1) (eq ?entrada 2)) then
            (printout t "=== Dados coletados com sucesso! ===" crlf)
        else
            ; Se a entrada não for 1, 2 ou 3, exibe mensagem de erro
            (printout t "Opção inválida. Tente novamente." crlf)
        )
    )
   
)

(defrule recomendar-arquitetura
    (declare (salience 70))
    (sistema_entrada
        (nome_sistema ?nome_sistema)
        (tamanho ?tamanho)
        (complexidade ?complexidade)
        (escalabilidade ?escalabilidade)
        (tamanho_equipe ?tamanho_equipe)
        (necessidade_integracao ?necessidade_integracao)
    )
    =>
    (do-for-all-facts ((?sistema sistema))
        (and
            (eq ?sistema:tamanho ?tamanho)
            (eq ?sistema:complexidade ?complexidade)
            (eq ?sistema:escalabilidade ?escalabilidade)
            (eq ?sistema:tamanho_equipe ?tamanho_equipe)
            (eq ?sistema:necessidade_integracao ?necessidade_integracao)
        )
        (assert (sistema_saida
                (nome_sistema ?nome_sistema)
                (tipo_banco ?sistema:tipo_banco)
                (stream_fila ?sistema:stream_fila)
                (tipo_arq ?sistema:tipo_arq))
        )
    )
)

(defrule exibir-recomendacao
    (declare (salience 60))
    (sistema_saida
        (nome_sistema ?nome_sistema)
        (tipo_banco ?tipo_banco)
        (stream_fila ?stream_fila)
        (tipo_arq ?tipo_arq)
    )
    =>
    ; Abre o arquivo no modo de escrita ("w" para sobrescrever, "a" para anexar)
    (open "C:\\Users\\orck1\\OneDrive\\Documentos\\pos-senai\\P-s-IA_SENAI\\Trabalho Final\\recomendacao.txt" recomendacao "a")

    (printout recomendacao "=== Recomendação para o Sistema: " ?nome_sistema " ===" crlf)
    (printout recomendacao "Tipo de Banco: " ?tipo_banco crlf)
    (printout recomendacao "Uso de Stream/Fila: " ?stream_fila crlf)
    (printout recomendacao "Tipo de Arquitetura: " ?tipo_arq crlf)

    ; Fecha o arquivo
    (close recomendacao)
)