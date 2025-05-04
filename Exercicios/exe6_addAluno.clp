(deftemplate estudante
    (slot nome (type STRING))
    (slot nota (type FLOAT) (default 0.0))
)

(defrule adicionar-item-teclado
    =>
    (printout t "Digite o nome do estudante: ")
    (bind ?nome (read))
    (printout t "Digite a nota (0.0 a 10): ")
    (bind ?nota (read))
    (if (and (or (stringp ?nome) (symbolp ?nome)) (numberp ?nota) (>= ?nota 0.0) (<= ?nota 10.0)) then
        (bind ?nome-str (if (symbolp ?nome) then (str-cat ?nome) else ?nome))
        (assert (estudante (nome ?nome-str) (nota ?nota)))
        (printout t "Estudante " ?nome " com nota " ?nota " adicionado." crlf)
    else 
        (printout t "Entrada inválida. Nome deve ser texto e nota número entre 0.0 e 10.0." crlf)

    )

)