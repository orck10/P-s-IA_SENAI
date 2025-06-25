; Sistema Especialista para Otimização de Linha de Produção

; Definição do Template para Equipamentos
(deftemplate equipamento
   (slot nome (type STRING))
   (slot tempo-ciclo (type FLOAT) (default 0.0))
   (slot disponibilidade (type FLOAT) (default 0.0))
   (slot qualidade (type FLOAT) (default 0.95)) ; Assumindo qualidade padrão de 95%
   (slot oee (type FLOAT) (default 0.0))
   (slot status (type STRING) (allowed-values "operacional" "em manutenção" "parado"))
   (slot carga-trabalho (type INTEGER) (default 100)))

; Definição do Template para Configurações da Linha
(deftemplate config-linha
   (slot oee-ideal (type FLOAT) (default 0.85))
   (slot oee-minimo (type FLOAT) (default 0.80)))

; Fatos de Teste
(deffacts teste-producao
   (equipamento (nome "Máquina 1") (tempo-ciclo 12.0) (disponibilidade 90.0) (status "operacional"))
   (equipamento (nome "Máquina 2") (tempo-ciclo 10.0) (disponibilidade 95.0) (status "operacional"))
   (equipamento (nome "Máquina 3") (tempo-ciclo 15.0) (disponibilidade 70.0) (status "operacional"))
)

; Função para Calcular OEE
(deffunction calcular-oee (?disp ?perf ?qual)
   (* (* ?disp ?perf) ?qual)
)

; Regra para Calcular OEE
(defrule calcular-oee
   ?eq <- (equipamento (nome ?nome)
                      (tempo-ciclo ?tc)
                      (disponibilidade ?disp)
                      (qualidade ?qual)
                      (oee 0.0))
   (test (> ?tc 0))
   =>
   (bind ?perf (/ 10 ?tc)) ; Performance simplificada: 10s é o tempo ideal
   (bind ?oee (calcular-oee (/ ?disp 100) ?perf (/ ?qual 100)))
   (modify ?eq (oee (* ?oee 100)))
)

; Regra para Monitorar Eficiência Baixa
(defrule monitorar-eficiencia-baixa
   (config-linha (oee-minimo ?min))
   ?eq <- (equipamento (nome ?nome)
                      (oee ?oee&:(< ?oee ?min))
                      (status "operacional"))
   =>
   (printout t "ALERTA: Equipamento " ?nome " com OEE baixo (" ?oee "%). Recomendando ações." crlf)
   (assert (recomendar-manutencao ?nome))
   (assert (ajustar-tempo-ciclo ?nome))
)

; Regra para Recomendar Manutenção
(defrule recomendar-manutencao
   ?rec <- (recomendar-manutencao ?nome)
   ?eq <- (equipamento (nome ?nome) (status "operacional"))
   =>
   (printout t "Recomendando manutenção preventiva para " ?nome crlf)
   (modify ?eq (status "em manutenção") (carga-trabalho 0))
   (retract ?rec)
   (assert (redistribuir-carga ?nome))
)

; Regra para Ajustar Tempo de Ciclo
(defrule ajustar-tempo-ciclo
   ?aj <- (ajustar-tempo-ciclo ?nome)
   ?eq <- (equipamento (nome ?nome) (tempo-ciclo ?tc) (status "operacional"))
   =>
   (bind ?novo-tc (* ?tc 0.9)) ; Reduz tempo de ciclo em 10%
   (printout t "Ajustando tempo de ciclo de " ?nome " de " ?tc "s para " ?novo-tc "s" crlf)
   (modify ?eq (tempo-ciclo ?novo-tc))
   (retract ?aj)
)

; Regra para Redistribuir Carga de Trabalho
(defrule redistribuir-carga
   (redistribuir-carga ?nome-falha)
   ?eq-falha <- (equipamento (nome ?nome-falha) (carga-trabalho ?carga&:(> ?carga 0)))
   ?eq-destino <- (equipamento (nome ?nome-destino&:(neq ?nome-destino ?nome-falha))
                              (oee ?oee-destino&:(>= ?oee-destino 80))
                              (status "operacional")
                              (carga-trabalho ?carga-destino))
   =>
   (bind ?nova-carga (+ ?carga-destino ?carga))
   (printout t "Redistribuindo carga de " ?nome-falha " para " ?nome-destino crlf)
   (modify ?eq-falha (carga-trabalho 0))
   (modify ?eq-destino (carga-trabalho ?nova-carga))
)

; Regra para Equipamentos com OEE Ideal
(defrule oee-ideal
   (config-linha (oee-ideal ?ideal))
   (equipamento (nome ?nome) (oee ?oee&:(>= ?oee ?ideal)) (status "operacional"))
   =>
   (printout t "Equipamento " ?nome " operando com OEE ideal (" ?oee "%)" crlf)
)

(defrule printar-estado-final
   (declare (salience -10)) ; Executa após todas as outras regras
   (equipamento (nome ?nome)
               (tempo-ciclo ?tc)
               (disponibilidade ?disp)
               (qualidade ?qual)
               (oee ?oee)
               (status ?stat)
               (carga-trabalho ?carga))
   =>
   (printout t "Estado Final - " ?nome ": " crlf
             "  Tempo de Ciclo: " ?tc "s" crlf
             "  Disponibilidade: " ?disp "%" crlf
             "  Qualidade: " ?qual "%" crlf
             "  OEE: " ?oee "%" crlf
             "  Status: " ?stat crlf
             "  Carga de Trabalho: " ?carga crlf crlf))