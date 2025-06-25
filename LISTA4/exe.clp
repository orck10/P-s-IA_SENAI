; Define o modelo para os dados das máquinas
(deftemplate maquina
   (slot nome (type STRING))
   (slot consumo-energetico (type FLOAT) (default 0.0))
   (slot eficiencia-energetica (type FLOAT) (default 0.0))
   (slot tempo-operacao (type FLOAT) (default 0.0))
   (slot limite-energia (type FLOAT) (default 0.0))
   (slot estado (type STRING) (allowed-values "operacional" "em-ajuste" "desligada"))
   (slot contagem-ineficiencia (type INTEGER) (default 0)))

; Define o modelo para redistribuição de produção
(deftemplate tarefa-producao
   (slot nome-maquina (type STRING))
   (slot unidades-a-produzir (type INTEGER)))

; Regra 1: Monitorar Consumo Energético
(defrule monitorar-consumo-energetico
   (maquina (nome ?nome) (consumo-energetico ?ce) (limite-energia ?le) (estado "operacional"))
   (test (> ?ce ?le))
   =>
   (printout t "ALERTA: Máquina " ?nome " excede o limite de energia (" ?ce " kWh > " ?le " kWh)." crlf)
   (assert (ajustar-maquina ?nome)))

; Regra 2: Avaliar Eficiência Energética
(defrule avaliar-eficiencia-energetica
   ?m <- (maquina (nome ?nome) (eficiencia-energetica ?ee) (estado "operacional") (contagem-ineficiencia ?ci))
   (test (< ?ee 80.0))
   =>
   (printout t "ALERTA: Máquina " ?nome " apresenta baixa eficiência energética (" ?ee "% < 80%)." crlf)
   (modify ?m (estado "em-ajuste") (contagem-ineficiencia (+ ?ci 1)))
   (assert (ajustar-maquina ?nome)))

; Regra 3: Ajustar Operação da Máquina
(defrule ajustar-operacao-maquina
   ?adj <- (ajustar-maquina ?nome)
   ?m <- (maquina (nome ?nome) (tempo-operacao ?to) (estado "operacional" | "em-ajuste"))
   (test (> ?to 8.0)) ; Assume que 8 horas é o limite para operação excessiva
   =>
   (printout t "AÇÃO: Reduzindo o tempo de operação da máquina " ?nome "." crlf)
   (modify ?m (tempo-operacao (- ?to 1.0)) (estado "em-ajuste"))
   (retract ?adj))

; Regra 4: Desligar Máquina se os Ajustes Falharem
(defrule desligar-maquina
   ?adj <- (ajustar-maquina ?nome)
   ?m <- (maquina (nome ?nome) (estado "em-ajuste") (consumo-energetico ?ce) (limite-energia ?le))
   (test (> ?ce ?le))
   =>
   (printout t "AÇÃO: Desligando a máquina " ?nome " devido ao consumo elevado persistente." crlf)
   (modify ?m (estado "desligada"))
   (retract ?adj)
   (assert (redistribuir-producao ?nome)))

; Regra 5: Redistribuir Produção
(defrule redistribuir-producao
   ?rd <- (redistribuir-producao ?maquina-antiga)
   ?m1 <- (maquina (nome ?maquina-antiga) (estado "desligada"))
   ?m2 <- (maquina (nome ?nova-maquina&~?maquina-antiga) (estado "operacional") (eficiencia-energetica ?ee))
   (test (>= ?ee 90.0))
   =>
   (printout t "AÇÃO: Redistribuindo produção de " ?maquina-antiga " para " ?nova-maquina "." crlf)
   (assert (tarefa-producao (nome-maquina ?nova-maquina) (unidades-a-produzir 100)))
   (retract ?rd))

; Regra 6: Recomendar Substituição de Máquina
(defrule recomendar-substituicao
   ?m <- (maquina (nome ?nome) (contagem-ineficiencia ?ci) (eficiencia-energetica ?ee))
   (test (>= ?ci 2))
   (test (< ?ee 80.0))
   =>
   (printout t "RECOMENDAÇÃO: Substituir a máquina " ?nome " devido à baixa eficiência persistente (" ?ee "%)." crlf))

; Função para imprimir o estado final das máquinas
(deffunction imprimir-estado-final ()
   (printout t crlf "=== Estado Final das Máquinas ===" crlf)
   (do-for-all-facts ((?m maquina)) TRUE
      (printout t "Máquina: " ?m:nome crlf
                  "  Consumo Energético: " ?m:consumo-energetico " kWh" crlf
                  "  Eficiência Energética: " ?m:eficiencia-energetica "%" crlf
                  "  Tempo de Operação: " ?m:tempo-operacao " horas" crlf
                  "  Limite de Energia: " ?m:limite-energia " kWh" crlf
                  "  Estado: " ?m:estado crlf
                  "  Contagem de Ineficiência: " ?m:contagem-ineficiencia crlf
                  "-------------------" crlf)))

; Cenário de Teste: Inicializar máquinas com dados de exemplo
(deffacts maquinas-iniciais
   (maquina (nome "Maquina1") (consumo-energetico 150.0) (eficiencia-energetica 75.0) (tempo-operacao 10.0) (limite-energia 120.0) (estado "operacional"))
   (maquina (nome "Maquina2") (consumo-energetico 100.0) (eficiencia-energetica 92.0) (tempo-operacao 6.0) (limite-energia 110.0) (estado "operacional"))
   (maquina (nome "Maquina3") (consumo-energetico 130.0) (eficiencia-energetica 78.0) (tempo-operacao 9.0) (limite-energia 125.0) (estado "operacional")))

; Função para reiniciar e executar o sistema
(defrule executar-sistema
    (declare (salience -10)) ; Executa após todas as outras regras
    =>
   (printout t "Monitoramento do sistema concluído." crlf)
   (imprimir-estado-final))