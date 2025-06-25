; === Exercício 4: Coleta de dados e recomendação de manutenção ===
; Crie um sistema que usa read para coletar ID e horas de operação de
; uma máquina, cria um fato, e usa uma regra para recomendar manutenção
; (ex.: "manutenção preventiva" se horas >= 1000, "continuar operação" se < 1000).

(deftemplate maquina
    (slot id (type STRING))
    (slot horas-operacao (type INTEGER) (default 0)))

(deftemplate recomendacao
    (slot id (type STRING))
    (slot acao (type STRING)))

(defrule coletar-dados-maquina
    =>
    (printout t "Digite o ID da máquina: ")
    (bind ?id (read))
    (printout t "Digite as horas de operação: ")
    (bind ?horas (read))
    (assert (maquina (id ?id) (horas-operacao ?horas))))

(defrule recomendar-manutencao
    (maquina (id ?id) (horas-operacao ?horas))
    =>
    (if (>= ?horas 1000) then
        (assert (recomendacao (id ?id) (acao "manutenção preventiva")))
    else
        (assert (recomendacao (id ?id) (acao "continuar operação")))))

(defrule processar-recomendacao
    (recomendacao (id ?id) (acao ?acao))
    =>
    (printout t "Recomendação para máquina " ?id ": " ?acao "." crlf))

; Teste com depth:
(set-strategy depth)
(assert (sensor (id "S002") (temperatura 110.0)))
(assert (sensor (id "S003") (temperatura 85.0)))
(assert (sensor (id "S004") (temperatura 60.0)))
(run)
; Saída (ordem depende da pilha, geralmente mais recente primeiro):
; Sensor S004: Temperatura normal 60°C.
; Sensor S003: ALERTA - Temperatura elevada 85°C.
; Sensor S002: ALERTA CRITICO - Temperatura 110°C!

