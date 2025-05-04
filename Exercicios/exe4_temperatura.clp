(deftemplate temperatura
    (slot dia (type SYMBOL))
    (slot valor (type FLOAT))
)

(deffacts temperatura-iniciais
    (temperatura (dia segunda) (valor 25.0))
    (temperatura (dia terça) (valor 22.5))
)

(defrule adicionar-temperatura
    =>
    (bind ?temp 20.0)
    (if (> ?temp -50) then
        (assert (temperatura (dia quarta) (valor ?temp)))
        (printout t "Temperatura de quarta (" ?temp "°C) registrada" crlf)
    else
        (printout t "Temperatura invalida: " ?temp "°C" crlf) 
    )
)

