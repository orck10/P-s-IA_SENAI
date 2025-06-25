; === Exercício 5: Testar estratégias de resolução para alertas de produção ===
; Crie um sistema com três regras que processam fatos de sensores
; (ID e temperatura). Cada regra gera um alerta diferente com base na temperatura.
; Teste as estratégias "depth" e "breadth" para observar a ordem de execução dos alertas.

(deftemplate sensor
    (slot id (type STRING))
    (slot temperatura (type FLOAT) (default 0.0)))

(defrule alerta-temperatura-critica
    (sensor (id ?id) (temperatura ?temp&:(> ?temp 100.0)))
    =>
    (printout t "Sensor " ?id ": ALERTA CRITICO - Temperatura " ?temp "°C!" crlf))

(defrule alerta-temperatura-elevada
    (sensor (id ?id) (temperatura ?temp&:(and (> ?temp 80.0) (< ?temp 100.0))))
    =>
    (printout t "Sensor " ?id ": ALERTA - Temperatura elevada " ?temp "°C." crlf))

(defrule alerta-temperatura-normal
    (sensor (id ?id) (temperatura ?temp&:(<= ?temp 80.0)))
    =>
    (printout t "Sensor " ?id ": Temperatura normal " ?temp "°C." crlf))




; Teste com breadth:
;(reset)
;(set-strategy breadth)
;(assert (sensor (id "S002") (temperatura 110.0)))
;(assert (sensor (id "S003") (temperatura 85.0)))
;(assert (sensor (id "S004") (temperatura 60.0)))
;(run)
; Saída (ordem FIFO):
; Sensor S002: ALERTA CRITICO - Temperatura 110°C!
; Sensor S003: ALERTA - Temperatura elevada 85°C.
; Sensor S004: Temperatura normal 60°C.