;Exercício 1: Controle de qualidade com especificações múltiplas

;Crie um sistema que verifica se uma peça industrial (definida por
;um template com slots para identificador, tolerância dimensional,
;resistência e peso) atende aos padrões de qualidade (tolerância <= 0.01 mm,
;resistência >= 500 MPa, peso entre 1.0 e 2.0 kg). Use uma regra para
;imprimir o resultado.

(deftemplate peca
    (slot identificador (type STRING))
    (slot tolerancia (type FLOAT) (default 0.0))
    (slot resistencia (type FLOAT) (default 0.0))
    (slot peso (type FLOAT) (default 0.0)))

(defrule verificar-qualidade
    ?peca <- (peca (identificador ?id)
                   (tolerancia ?tol&:(<= ?tol 0.01))
                   (resistencia ?res&:(>= ?res 500.0))
                   (peso ?peso&:(and (>= ?peso 1.0) (<= ?peso 2.0))))
    =>
    (printout t "Peca " ?id " atende aos padroes de qualidade. Tolerancia: " ?tol " mm, Resistencia: " ?res " MPa, Peso: " ?peso " kg." crlf))

;Teste:
;(reset)
;(assert (peca (identificador "P001") (tolerancia 0.005) (resistencia 550.0) (peso 1.5)))
;(assert (peca (identificador "P002") (tolerancia 0.02) (resistencia 600.0) (peso 1.8)))
;(run)

;Saída esperada: Peca P001 atende aos padroes de qualidade. Tolerancia: 0.005 mm, Resistencia: 550 MPa, Peso: 1.5 kg.