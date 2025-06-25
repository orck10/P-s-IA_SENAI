; === Exercício 3: Coleta de dados de sensor e classificação de temperatura === 
; Crie um sistema que usa read para coletar dados de um sensor
; (ID do sensor, temperatura e pressão), cria um fato com esses dados usando
; assert, e usa uma regra para classificar a temperatura
; (ex.: "crítica" se >= 100°C, "normal" se entre 50 e 100°C, "baixa" se < 50°C).

(deftemplate sensor
    (slot id (type STRING))
    (slot temperatura (type FLOAT) (default 0.0))
    (slot pressao (type FLOAT) (default 0.0)))

(defrule coletar-dados-sensor
    =>
    (printout t "Digite o ID do sensor: ")
    (bind ?id (read))
    (printout t "Digite a temperatura (°C): ")
    (bind ?temp (read))
    (printout t "Digite a pressão (bar): ")
    (bind ?press (read))
    (assert (sensor (id ?id) (temperatura ?temp) (pressao ?press))))

(defrule classificar-temperatura
    (sensor (id ?id) (temperatura ?temp))
    =>
    (if (> ?temp 100.0) then
        (printout t "Sensor " ?id ": temperatura critica (" ?temp "°C)." crlf)
    else
        (if (>= ?temp 50.0) then
            (printout t "Sensor " ?id ": temperatura normal (" ?temp "°C)." crlf)
        else
            (printout t "Sensor " ?id ": temperatura baixa (" ?temp "°C)." crlf))))