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
)

(defrule classificar-doentes
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
)

(deffunction imprimir-pessoa (?pessoa)
   (printout t "- " (fact-slot-value ?pessoa nome) " (" (fact-slot-value ?pessoa temperatura) "°C)" crlf)
)

(defrule imprimir-pacientes
   (Pacientes (alta $?alta) (doentes $?doentes))
   =>
   (printout t crlf "Pacientes com alta:" crlf)
   (foreach ?pessoa ?alta
      (imprimir-pessoa ?pessoa)
   )

   (printout t crlf "Pacientes doentes:" crlf)
   (foreach ?pessoa ?doentes
      (imprimir-pessoa ?pessoa)
   )
)
