(deftemplate temperatura
    (slot dia (type SYMBOL))
    (slot valor (type FLOAT))
)

(defrule adicionar-temperatura-teclado
    =>
    (printout t "Digite o dia (ex.: segunta, terça): ")
    (bind ?dia (read))
    (printout t "Digite a temperaturA (°C): ")
    (bind ?temp (read))
    (if (and (symbolp ?dia) (numberp ?temp) (> ?temp -50.0) (< ?temp 50.0)) then
        (assert (temperatura (dia ?dia) (valor ?temp)))
        (printout t "Temperatura de " ?dia "(" ?temp "°C) registrada." crlf) 
    else
        (printout t "Entrada inválida. Dia deve ser um simbolo e temperatura entre -50.0 e 50.0." crlf)
    )
)