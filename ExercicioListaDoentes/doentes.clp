(deftemplate Pessoa
   (slot nome (type STRING))
   (slot temperatura (type FLOAT))
)

(deftemplate Pacientes
   (multislot alta)
   (multislot doentes)
)

(deffacts pessoas-iniciais
   (Pessoa (nome "Alice") (temperatura 36.5))
   (Pessoa (nome "Bruno") (temperatura 37.2))
   (Pessoa (nome "Carla") (temperatura 38.1))
   (Pessoa (nome "Daniel") (temperatura 39.0))
   (Pessoa (nome "Elisa") (temperatura 36.8))
   (Pacientes (alta) (doentes))
)

(defrule classificar-doentes
   (Pacientes)
   =>
   (bind ?doentes (create$))
   (bind ?alta (create$))
   
   (bind ?pessoas (find-all-facts ((?p Pessoa)) TRUE))
   (foreach ?p ?pessoas
      (if (> (fact-slot-value ?p temperatura) 37.0)
         then
            (bind ?doentes (create$ ?doentes ?p))
         else
            (bind ?alta (create$ ?alta ?p))
      )
   )
   
   (assert (Pacientes (alta ?alta) (doentes ?doentes)))
; Imprime os resultados
   (printout t "Pacientes classificados!" crlf)
   (printout t "Doentes:" crlf)
   (foreach ?d ?doentes
      (printout t " - " (fact-slot-value ?d nome) " (" (fact-slot-value ?d temperatura) ")" crlf)
   )
   (printout t "Alta:" crlf)
   (foreach ?a ?alta
      (printout t " - " (fact-slot-value ?a nome) " (" (fact-slot-value ?a temperatura) ")" crlf)
   )
)

(defrule finalizar
   ?p <- (Pacientes (alta ?alta) (doentes ?doentes))
   =>
   (printout t "Sistema finalizado!" crlf)
   (retract ?p)
)


