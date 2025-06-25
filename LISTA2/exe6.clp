; === Exercício 6: Testar estratégias com manutenção prioritária ===
; Crie um sistema com duas regras que processam o mesmo fato de máquina
; (horas de operação >= 1000), gerando recomendações de manutenção com diferentes
; prioridades. Use saliência para influenciar a prioridade e teste as estratégias
; "depth" e "breadth".

(deftemplate maquina
    (slot id (type STRING))
    (slot horas-operacao (type INTEGER) (default 0)))

(defrule manutencao-urgente
    (declare (salience 10))
    (maquina (id ?id) (horas-operacao ?horas&:(> ?horas 1000)))
    =>
    (printout t "Máquina " ?id ": Manutenção URGENTE necessária (" ?horas " horas)." crlf))

(defrule manutencao-planejada
    (declare (salience 0))
    (maquina (id ?id) (horas-operacao ?horas&:(> ?horas 1000)))
    =>
    (printout t "Máquina " ?id ": Agendar manutenção planejada (" ?horas " horas)." crlf))

; Teste com depth:
;(reset)
;(set-strategy depth)
;(assert (maquina (id "M002") (horas-operacao 1500)))
;(run)
; Saída (salience domina, depth favorece mais recente):
; Máquina M002: Manutenção URGENTE necessária (1500 horas).
; Máquina M002: Agendar manutenção planejada (1500 horas).

; Teste com breadth:
;(reset)
;(set-strategy breadth)
;(assert (maquina (id "M002") (horas-operacao 1500)))
;(run)
; Saída (salience domina, breadth mantém ordem FIFO):
; Máquina M002: Manutenção URGENTE necessária (1500 horas).
; Máquina M002: Agendar manutenção planejada (1500 horas).