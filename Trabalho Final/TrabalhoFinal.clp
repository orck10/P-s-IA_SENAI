; Definição de templates para características do sistema
(deftemplate sistema
   (slot tamanho (type SYMBOL) (allowed-values pequeno medio grande))
   (slot complexidade (type SYMBOL) (allowed-values baixa media alta))
   (slot escalabilidade (type SYMBOL) (allowed-values baixa media alta))
   (slot tamanho_equipe (type SYMBOL) (allowed-values pequena media grande))
   (slot necessidade_integracao (type SYMBOL) (allowed-values baixa media alta))
   (slot tipo_banco (type SYMBOL) (allowed-values SQL NoSQL))
   (slot stream_fila (type SYMBOL) (allowed-values sim nao))
)

; Definição de template para recomendação
(deftemplate recomendacao
   (slot arquitetura (type SYMBOL) (allowed-values MVC Microservicos))
)

; Regras para recomendação de arquitetura
(defrule recomendar-MVC-pequeno
   (sistema 
      (tamanho pequeno)
      (complexidade ?c&baixa|media)
      (escalabilidade ?e&baixa|media)
      (tamanho_equipe ?te&pequena|media)
      (necessidade_integracao ?ni&baixa|media)
      (tipo_banco SQL)
      (stream_fila nao))
   =>
   (assert (recomendacao (arquitetura MVC)))
   (printout t "Recomendado: MVC - Projetos pequenos com baixa a média complexidade, escalabilidade e integração, usando banco SQL e sem filas, são ideais para MVC." crlf)
)

(defrule recomendar-MVC-medio
   (sistema 
      (tamanho medio)
      (complexidade ?c&baixa|media)
      (escalabilidade ?e&baixa|media)
      (tamanho_equipe ?te&pequena|media)
      (necessidade_integracao baixa)
      (tipo_banco SQL)
      (stream_fila nao))
   =>
   (assert (recomendacao (arquitetura MVC)))
   (printout t "Recomendado: MVC - Projetos médios com baixa integração, complexidade moderada, banco SQL e sem filas se beneficiam da simplicidade do MVC." crlf)
)

(defrule recomendar-Microservicos-grande
   (sistema 
      (tamanho grande)
      (complexidade ?c&media|alta)
      (escalabilidade alta)
      (tamanho_equipe ?te&media|grande)
      (necessidade_integracao ?ni&media|alta)
      (tipo_banco ?tb&SQL|NoSQL)
      (stream_fila ?sf&sim|nao))
   =>
   (assert (recomendacao (arquitetura Microservicos)))
   (printout t "Recomendado: Microserviços - Projetos grandes com alta escalabilidade e integração são ideais para microserviços, independentemente do banco ou uso de filas." crlf)
)

(defrule recomendar-Microservicos-alta-integracao
   (sistema 
      (tamanho ?t&medio|grande)
      (complexidade alta)
      (escalabilidade ?e&media|alta)
      (tamanho_equipe grande)
      (necessidade_integracao alta)
      (tipo_banco NoSQL)
      (stream_fila sim))
   =>
   (assert (recomendacao (arquitetura Microservicos)))
   (printout t "Recomendado: Microserviços - Alta complexidade, integração, uso de NoSQL e filas favorecem microserviços para maior flexibilidade." crlf)
)

(defrule recomendar-Microservicos-medio-escalabilidade-alta
   (sistema 
      (tamanho medio)
      (complexidade ?c&baixa|media)
      (escalabilidade alta)
      (tamanho_equipe pequena)
      (necessidade_integracao ?ni&baixa|media)
      (tipo_banco ?tb&SQL|NoSQL)
      (stream_fila ?sf&sim|nao))
   =>
   (assert (recomendacao (arquitetura Microservicos)))
   (printout t "Recomendado: Microserviços - Projetos médios com alta escalabilidade, mesmo com equipe pequena, se beneficiam da modularidade dos microserviços, mas considere a sobrecarga de gerenciamento." crlf)
)

(defrule recomendar-Microservicos-pequeno-alta-complexidade
   (sistema 
      (tamanho pequeno)
      (complexidade alta)
      (escalabilidade alta)
      (tamanho_equipe pequena)
      (necessidade_integracao ?ni&baixa|media)
      (tipo_banco NoSQL)
      (stream_fila nao))
   =>
   (assert (recomendacao (arquitetura Microservicos)))
   (printout t "Recomendado: Microserviços - Projetos pequenos com alta complexidade e escalabilidade, usando NoSQL, se beneficiam da modularidade dos microserviços. No entanto, com uma equipe pequena, considere os desafios de gerenciamento e manutenção." crlf)
)

(defrule recomendar-Microservicos-nosql-fila
   (sistema 
      (tamanho ?t&medio|grande)
      (complexidade ?c&media|alta)
      (escalabilidade ?e&media|alta)
      (tamanho_equipe ?te&media|grande)
      (necessidade_integracao ?ni&media|alta)
      (tipo_banco NoSQL)
      (stream_fila sim))
   =>
   (assert (recomendacao (arquitetura Microservicos)))
   (printout t "Recomendado: Microserviços - Uso de NoSQL e filas em projetos médios a grandes com escalabilidade e integração média a alta favorecem microserviços." crlf)
)

(defrule caso-indeciso
   (sistema 
      (tamanho medio)
      (complexidade media)
      (escalabilidade media)
      (tamanho_equipe media)
      (necessidade_integracao media)
      (tipo_banco ?tb&SQL|NoSQL)
      (stream_fila ?sf&sim|nao))
   =>
   (printout t "Indecisão: Tanto MVC quanto Microserviços podem ser viáveis. Considere MVC para simplicidade ou Microserviços para futura escalabilidade e flexibilidade com NoSQL/filas." crlf)
)

; Função para coletar entrada do usuário
(deffunction coletar-entrada (?campo ?valores-permitidos)
   (printout t "Digite o valor para " ?campo " (" ?valores-permitidos "): ")
   (bind ?resposta (read))
   (while (not (member$ ?resposta ?valores-permitidos))
      (printout t "Valor inválido! Digite um valor válido para " ?campo " (" ?valores-permitidos "): ")
      (bind ?resposta (read)))
   ?resposta
)

; Regra inicial para coletar dados e iniciar o sistema
(defrule iniciar-sistema
   =>
   (printout t "=== Sistema de Recomendação de Arquitetura ===" crlf)
   (bind ?tamanho (coletar-entrada "tamanho do projeto" (create$ pequeno medio grande)))
   (bind ?complexidade (coletar-entrada "complexidade do projeto" (create$ baixa media alta)))
   (bind ?escalabilidade (coletar-entrada "necessidade de escalabilidade" (create$ baixa media alta)))
   (bind ?tamanho_equipe (coletar-entrada "tamanho da equipe" (create$ pequena media grande)))
   (bind ?necessidade_integracao (coletar-entrada "necessidade de integração" (create$ baixa media alta)))
   (bind ?tipo_banco (coletar-entrada "tipo de banco de dados" (create$ SQL NoSQL)))
   (bind ?stream_fila (coletar-entrada "uso de stream de dados em fila" (create$ sim nao)))
   (assert (sistema 
              (tamanho ?tamanho)
              (complexidade ?complexidade)
              (escalabilidade ?escalabilidade)
              (tamanho_equipe ?tamanho_equipe)
              (necessidade_integracao ?necessidade_integracao)
              (tipo_banco ?tipo_banco)
              (stream_fila ?stream_fila)
            )
   )             
)

