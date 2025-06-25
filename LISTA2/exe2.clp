;Exercício 2: Controle de qualidade com status de produção

;Crie um sistema que verifica se uma peça atende aos padrões
;(tolerância <= 0.01 mm, resistência >= 500 MPa). Se aprovada, crie um fato
;com status "aprovada" para envio à linha de montagem.
;Use uma regra para processar esse status e imprimir uma mensagem.

(deftemplate peca
    (slot id (type STRING))
    (slot tolerancia (type FLOAT) (default 0.0))
    (slot resistencia (type FLOAT) (default 0.0)))

(deftemplate status-producao
    (slot id (type STRING))
    (slot resultado (type STRING)))

(defrule verificar-qualidade
    (peca (id ?id) (tolerancia ?tol&:(<= ?tol 0.01)) (resistencia ?res&:(>= ?res 500.0)))
    =>
    (assert (status-producao (id ?id) (resultado "aprovada"))))

(defrule processar-status
    (status-producao (id ?id) (resultado "aprovada"))
    =>
    (printout t "Peca " ?id " aprovada para montagem." crlf))

;Teste:
;(reset)
;(assert (peca (id "P003") (tolerancia 0.008) (resistencia 520.0)))
;(assert (peca (id "P004") (tolerancia 0.015) (resistencia 480.0)))
;(run)

;Saída: Peca P003 aprovada para montagem.