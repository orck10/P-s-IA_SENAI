
(deftemplate produto
   (slot identificador (type STRING))
   (slot peso (type FLOAT))
   (slot resistencia (type FLOAT))
   (slot defeitos-visuais (type INTEGER))
)

(deftemplate classificacao
   (slot identificador (type STRING))
   (slot resultado (type STRING))
)


(defrule coleta-dados
   =>
   (printout t "Insira o identificador do produto: ")
   (bind ?id (read))
   (printout t "Insira o peso do produto (kg): ")
   (bind ?peso (read))
   (printout t "Insira a resistência do produto (MPa): ")
   (bind ?resistencia (read))
   (printout t "Insira o número de defeitos visuais: ")
   (bind ?defeitos (read))
   (assert (produto (identificador ?id) (peso ?peso) (resistencia ?resistencia) (defeitos-visuais ?defeitos)))
)


(defrule rejeicao-peso-invalido
   (produto (identificador ?id) (peso ?peso))
   (or (test (< ?peso 1.0)) (test (> ?peso 2.0)))
   =>
   (assert (classificacao (identificador ?id) (resultado "rejeitado por peso inválido")))

)


(defrule rejeicao-baixa-resistencia
   (produto (identificador ?id) (resistencia ?resistencia))
   (test (< ?resistencia 500.0))
   =>
   (assert (classificacao (identificador ?id) (resultado "rejeitado por baixa resistência")))

)


(defrule rejeicao-defeitos-visuais
   (produto (identificador ?id) (defeitos-visuais ?defeitos))
   (test (> ?defeitos 2))
   =>
   (assert (classificacao (identificador ?id) (resultado "rejeitado por defeitos visuais")))

)


(defrule aprovacao-produto
   (produto (identificador ?id) (peso ?peso) (resistencia ?resistencia) (defeitos-visuais ?defeitos))
   (test (>= ?peso 1.0))
   (test (<= ?peso 2.0))
   (test (>= ?resistencia 500.0))
   (test (<= ?defeitos 2))
   (not (classificacao (identificador ?id) (resultado ?)))
   =>
   (assert (classificacao (identificador ?id) (resultado "aprovado")))

)


(defrule processa-classificacao
   (classificacao (identificador ?id) (resultado ?resultado))
   =>
   (printout t crlf "Resultado da inspeção para o produto " ?id ": " ?resultado crlf)
)


