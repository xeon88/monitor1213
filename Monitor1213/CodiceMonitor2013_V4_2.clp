; Questo programma contiene la bozza di codice CLIPS per MONITOR 2013;; Una descrizione metodologica è contenuta nel file Monitor-2013
(defmodule MAIN (export ?ALL));; LE AZIONI CHE PUÓ FARE UAV:
(deftemplate exec
      (slot step) 
      (slot action 
      (allowed-values go-forward go-left go-right loiter loiter-monitoring inform done))
      (slot param1)
      (slot param2)
      (slot param3 (allowed-values ok flood initial-flood severe-flood)))
;; lo stato globale fornito dal sistema(deftemplate status (slot step) (slot time) (slot result) )
;; la percezione visiva fornita dopo ogni azione(deftemplate perc-vision
          (slot step)
          (slot time)
          (slot pos-r)
          (slot pos-c)
          (slot direction (allowed-values  north west south east))
          (slot perc1 (allowed-values  urban rural hill water gate border))
          (slot perc2 (allowed-values  urban rural hill water gate border))
          (slot perc3 (allowed-values  urban rural hill water gate border))
          (slot perc4 (allowed-values  urban rural hill water gate border))
          (slot perc5 (allowed-values  urban rural water))
	      (slot perc6 (allowed-values  urban rural hill water gate border))
          (slot perc7 (allowed-values  urban rural hill water gate border))
          (slot perc8 (allowed-values  urban rural hill water gate border))
          (slot perc9 (allowed-values  urban rural hill water gate border))
          )
;; La percezione perc-monitor viene restituita dal modulo ENV solo quando al 
;; passo precedente è stata eseguita una azione di LoiterMonitor. 
;; Nello slot perc viene restituita la percezione precisa che è other se il 
;; monitoraggio preciso viene richiesto su una cella che non contiene acqua.(deftemplate perc-monitor
               (slot step)
               (slot time)
               (slot pos-r)
               (slot pos-c)
               (slot perc  (allowed-values low-water deep-water other)))
;; l’agente ha una conoscenza a priori su come è fatto l’ambiente PRIMA 
;; degli eventi meteorologici che sono causa dell’esondazione. 
;; Questa  conoscenza a priori è definita nel MAIN e quindi è accessibile anche all’agente.(deftemplate prior_cell 
                  (slot pos-r)
                  (slot pos-c)
                  (slot type (allowed-values urban rural lake hill gate border)))
; questa asserzione va ovviamente cambiata a seconda del tipo di ambiente che
; si utilizza
(deffacts init (create) (maxduration 1000))
(deffacts initialmap
             (prior_cell (pos-r 1) (pos-c 1) (type border))
             (prior_cell (pos-r 1) (pos-c 2) (type border))
             (prior_cell (pos-r 1) (pos-c 3) (type border))
             (prior_cell (pos-r 1) (pos-c 4) (type border))
             (prior_cell (pos-r 1) (pos-c 5) (type gate))
             (prior_cell (pos-r 1) (pos-c 6) (type border))
             (prior_cell (pos-r 1) (pos-c 7) (type border))
             (prior_cell (pos-r 1) (pos-c 8) (type border))
             (prior_cell (pos-r 1) (pos-c 9) (type gate))
             (prior_cell (pos-r 1) (pos-c 10) (type border))
             (prior_cell (pos-r 1) (pos-c 11) (type border))
             (prior_cell (pos-r 2) (pos-c 1) (type border))
             (prior_cell (pos-r 2) (pos-c 2) (type urban))
             (prior_cell (pos-r 2) (pos-c 3) (type hill))
             (prior_cell (pos-r 2) (pos-c 4) (type hill))
             (prior_cell (pos-r 2) (pos-c 5) (type rural))
             (prior_cell (pos-r 2) (pos-c 6) (type rural))
             (prior_cell (pos-r 2) (pos-c 7) (type rural))
             (prior_cell (pos-r 2) (pos-c 8) (type rural))
             (prior_cell (pos-r 2) (pos-c 9) (type lake))
             (prior_cell (pos-r 2) (pos-c 10) (type rural))
             (prior_cell (pos-r 2) (pos-c 11) (type border))
             (prior_cell (pos-r 3) (pos-c 1) (type border))
             (prior_cell (pos-r 3) (pos-c 2) (type lake))
             (prior_cell (pos-r 3) (pos-c 3) (type urban))
             (prior_cell (pos-r 3) (pos-c 4) (type hill))
             (prior_cell (pos-r 3) (pos-c 5) (type urban))
             (prior_cell (pos-r 3) (pos-c 6) (type rural))
             (prior_cell (pos-r 3) (pos-c 7) (type rural))
             (prior_cell (pos-r 3) (pos-c 8) (type rural))
             (prior_cell (pos-r 3) (pos-c 9) (type rural))
             (prior_cell (pos-r 3) (pos-c 10) (type lake))
             (prior_cell (pos-r 3) (pos-c 11) (type border))
             (prior_cell (pos-r 4) (pos-c 1) (type border))
             (prior_cell (pos-r 4) (pos-c 2) (type lake))
             (prior_cell (pos-r 4) (pos-c 3) (type urban))
             (prior_cell (pos-r 4) (pos-c 4) (type urban))
             (prior_cell (pos-r 4) (pos-c 5) (type rural))
             (prior_cell (pos-r 4) (pos-c 6) (type rural))
             (prior_cell (pos-r 4) (pos-c 7) (type hill))
             (prior_cell (pos-r 4) (pos-c 8) (type rural))
             (prior_cell (pos-r 4) (pos-c 9) (type rural))
             (prior_cell (pos-r 4) (pos-c 10) (type lake))
             (prior_cell (pos-r 4) (pos-c 11) (type border))
             (prior_cell (pos-r 5) (pos-c 1) (type border))
             (prior_cell (pos-r 5) (pos-c 2) (type lake))
             (prior_cell (pos-r 5) (pos-c 3) (type lake))
             (prior_cell (pos-r 5) (pos-c 4) (type rural))
             (prior_cell (pos-r 5) (pos-c 5) (type rural))
             (prior_cell (pos-r 5) (pos-c 6) (type hill))
             (prior_cell (pos-r 5) (pos-c 7) (type rural))
             (prior_cell (pos-r 5) (pos-c 8) (type rural))
             (prior_cell (pos-r 5) (pos-c 9) (type lake))
             (prior_cell (pos-r 5) (pos-c 10) (type urban))
             (prior_cell (pos-r 5) (pos-c 11) (type border))
	         (prior_cell (pos-r 6) (pos-c 1) (type border))
             (prior_cell (pos-r 6) (pos-c 2) (type rural))
             (prior_cell (pos-r 6) (pos-c 3) (type lake))
             (prior_cell (pos-r 6) (pos-c 4) (type rural))
             (prior_cell (pos-r 6) (pos-c 5) (type hill))
             (prior_cell (pos-r 6) (pos-c 6) (type rural))
             (prior_cell (pos-r 6) (pos-c 7) (type urban))
             (prior_cell (pos-r 6) (pos-c 8) (type lake))
             (prior_cell (pos-r 6) (pos-c 9) (type urban))
             (prior_cell (pos-r 6) (pos-c 10) (type rural))
             (prior_cell (pos-r 6) (pos-c 11) (type border))
             (prior_cell (pos-r 7) (pos-c 1) (type gate))
             (prior_cell (pos-r 7) (pos-c 2) (type rural))
             (prior_cell (pos-r 7) (pos-c 3) (type rural))
             (prior_cell (pos-r 7) (pos-c 4) (type rural))
             (prior_cell (pos-r 7) (pos-c 5) (type rural))
             (prior_cell (pos-r 7) (pos-c 6) (type urban))
             (prior_cell (pos-r 7) (pos-c 7) (type lake))
             (prior_cell (pos-r 7) (pos-c 8) (type hill))
             (prior_cell (pos-r 7) (pos-c 9) (type urban))
             (prior_cell (pos-r 7) (pos-c 10) (type rural))
             (prior_cell (pos-r 7) (pos-c 11) (type gate))
             (prior_cell (pos-r 8) (pos-c 1) (type border))
             (prior_cell (pos-r 8) (pos-c 2) (type urban))
             (prior_cell (pos-r 8) (pos-c 3) (type rural))
             (prior_cell (pos-r 8) (pos-c 4) (type urban))
             (prior_cell (pos-r 8) (pos-c 5) (type rural))
             (prior_cell (pos-r 8) (pos-c 6) (type urban))
             (prior_cell (pos-r 8) (pos-c 7) (type lake))
             (prior_cell (pos-r 8) (pos-c 8) (type rural))
             (prior_cell (pos-r 8) (pos-c 9) (type hill))
             (prior_cell (pos-r 8) (pos-c 10) (type hill))
             (prior_cell (pos-r 8) (pos-c 11) (type border))
             (prior_cell (pos-r 9) (pos-c 1) (type border))
             (prior_cell (pos-r 9) (pos-c 2) (type urban))
             (prior_cell (pos-r 9) (pos-c 3) (type urban))
             (prior_cell (pos-r 9) (pos-c 4) (type rural))
             (prior_cell (pos-r 9) (pos-c 5) (type rural))
             (prior_cell (pos-r 9) (pos-c 6) (type rural))
             (prior_cell (pos-r 9) (pos-c 7) (type rural))
             (prior_cell (pos-r 9) (pos-c 8) (type lake))
             (prior_cell (pos-r 9) (pos-c 9) (type hill))
             (prior_cell (pos-r 9) (pos-c 10) (type hill))
             (prior_cell (pos-r 9) (pos-c 11) (type border))
             (prior_cell (pos-r 10) (pos-c 1) (type border))
             (prior_cell (pos-r 10) (pos-c 2) (type border))
             (prior_cell (pos-r 10) (pos-c 3) (type border))
             (prior_cell (pos-r 10) (pos-c 4) (type border))
             (prior_cell (pos-r 10) (pos-c 5) (type border))
             (prior_cell (pos-r 10) (pos-c 6) (type border))
             (prior_cell (pos-r 10) (pos-c 7) (type gate))
             (prior_cell (pos-r 10) (pos-c 8) (type border))
             (prior_cell (pos-r 10) (pos-c 9) (type border))
             (prior_cell (pos-r 10) (pos-c 10) (type border))
             (prior_cell (pos-r 10) (pos-c 11) (type border))
             )
(defrule createworld 
    ?f<-   (create) =>
           (assert (create-actual-map) (create-initial-setting) (create-discovered))  
           (retract ?f)
           (focus ENV))        
;; SI PASSA AL MODULO AGENT SE NON  E' ESAURITO IL TEMPO (indicato da maxduration)
(defrule go-on-agent
   (declare (salience 20))
        (maxduration ?d)
        (status (time ?t&:(< ?t ?d)) (result no))
 => 
        ;(printout t crlf crlf)
        ;(printout t "vado ad agent  " ?t)
        (focus AGENT))
;; tempo esaurito
(defrule finish1
   (declare (salience 20))
        (maxduration ?d)
        (status (time ?t) (result no))
        (test (or (> ?t ?d) (= ?t ?d)))
        (penalty ?p)
          =>       
          (printout t crlf crlf)
          (printout t "time over   " ?t)
          (printout t crlf crlf)
          (printout t "penalty:" (+ ?p 10000000))
          (printout t crlf crlf)
          (halt))
;; l'agent ha dichiarato che ha terminato il suo compito (messaggio done)
(defrule finish2
   (declare (salience 20))
        (status (time ?t) (result done))
        (penalty ?p)
          => 
          (printout t crlf crlf)
          (printout t "done at time   " ?t)
          (printout t crlf crlf)
          (printout t "penalty:" ?p)
          (printout t crlf crlf)
          (halt))
;; SI BLOCCA TUTTO SE OCCORRE DISASTER 
(defrule disaster
   (declare (salience 20))
        (status (time ?t) (result disaster))
 => 
        (printout t crlf crlf)
        (printout t "Sorry, UAV has been gone lost at time:" ?t)
        (printout t crlf crlf)
        (halt))
;;  SI PASSA AL MODULO ENV DOPO CHE AGENTE HA DECISO L'AZIONE DA FARE
(defrule go-on-env	
	(declare (salience 21))
?f1<-	(status (step ?i))
	(exec (step ?i)) 
=>
	(printout t crlf)
	(focus ENV))
;;;;   *****************************
;;;;   *****************************
;;                 MODULO ENV;;;;   *****************************
(defmodule ENV (import MAIN ?ALL)(export ?ALL))
;; OGNI CELLA CONTIENE IL NUMERO DI RIGA E DI COLONNA , che COSA CONTIENE all’inizio (type) e il suo stato vero (actual) 
(deftemplate actual_cell 
                  (slot pos-r)
                  (slot pos-c)
                  (slot type (allowed-values urban rural lake hill gate border))
                  (slot actual (allowed-values ok  initial-flood severe-flood)))
(deftemplate agentstatus 
           (slot time) 
           (slot step) 
           (slot pos-r) 
           (slot pos-c)
           (slot direction)
           (slot dur-last-act))
(deftemplate discovered 
	(slot step)
	(slot pos-r)
	(slot pos-c) 
	(slot utility)
    (slot discover)
	(slot abstract)
    (slot precise))                         
(defrule creation1
 (declare (salience 25))
 ?f1 <-   (create-actual-map)
 =>
     (assert (actual_cell (pos-r 1) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 2) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 3) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 4) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 5) (type gate) (actual ok))
             (actual_cell (pos-r 1) (pos-c 6) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 7) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 8) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 9) (type gate) (actual ok))
             (actual_cell (pos-r 1) (pos-c 10) (type border) (actual ok))
             (actual_cell (pos-r 1) (pos-c 11) (type border) (actual ok))
             (actual_cell (pos-r 2) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 2) (pos-c 2) (type urban) (actual initial-flood ))
             (actual_cell (pos-r 2) (pos-c 3) (type hill) (actual ok))
             (actual_cell (pos-r 2) (pos-c 4) (type hill) (actual ok))
             (actual_cell (pos-r 2) (pos-c 5) (type rural) (actual ok))
             (actual_cell (pos-r 2) (pos-c 6) (type rural) (actual ok))
             (actual_cell (pos-r 2) (pos-c 7) (type rural) (actual ok))
             (actual_cell (pos-r 2) (pos-c 8) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 2) (pos-c 9) (type lake) (actual ok))
             (actual_cell (pos-r 2) (pos-c 10) (type rural) (actual ok))
             (actual_cell (pos-r 2) (pos-c 11) (type border) (actual ok))
             (actual_cell (pos-r 3) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 3) (pos-c 2) (type lake) (actual ok))
             (actual_cell (pos-r 3) (pos-c 3) (type urban) (actual initial-flood ))
             (actual_cell (pos-r 3) (pos-c 4) (type hill) (actual ok))
             (actual_cell (pos-r 3) (pos-c 5) (type urban) (actual ok))
             (actual_cell (pos-r 3) (pos-c 6) (type rural) (actual ok))
             (actual_cell (pos-r 3) (pos-c 7) (type rural) (actual ok))
             (actual_cell (pos-r 3) (pos-c 8) (type rural) (actual ok))             (actual_cell (pos-r 3) (pos-c 9) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 3) (pos-c 10) (type lake) (actual ok))
             (actual_cell (pos-r 3) (pos-c 11) (type border) (actual ok))
             (actual_cell (pos-r 4) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 4) (pos-c 2) (type lake) (actual ok))
             (actual_cell (pos-r 4) (pos-c 3) (type urban) (actual initial-flood ))
             (actual_cell (pos-r 4) (pos-c 4) (type urban) (actual ok))
             ;;(actual_cell (pos-r 4) (pos-c 4) (type urban) (actual initial-flood))
             (actual_cell (pos-r 4) (pos-c 5) (type rural) (actual ok))
             (actual_cell (pos-r 4) (pos-c 6) (type rural) (actual ok))
             (actual_cell (pos-r 4) (pos-c 7) (type hill) (actual ok))
             (actual_cell (pos-r 4) (pos-c 8) (type rural) (actual ok))
             (actual_cell (pos-r 4) (pos-c 9) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 4) (pos-c 10) (type lake) (actual ok))
             (actual_cell (pos-r 4) (pos-c 11) (type border) (actual ok))
             (actual_cell (pos-r 5) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 5) (pos-c 2) (type lake) (actual ok))
             (actual_cell (pos-r 5) (pos-c 3) (type lake) (actual ok))
             (actual_cell (pos-r 5) (pos-c 4) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 5) (pos-c 5) (type rural) (actual ok))
             (actual_cell (pos-r 5) (pos-c 6) (type hill) (actual ok))
             (actual_cell (pos-r 5) (pos-c 7) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 5) (pos-c 8) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 5) (pos-c 9) (type lake) (actual ok))
             (actual_cell (pos-r 5) (pos-c 10) (type urban) (actual initial-flood))
             (actual_cell (pos-r 5) (pos-c 11) (type border) (actual ok))
	         (actual_cell (pos-r 6) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 6) (pos-c 2) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 6) (pos-c 3) (type lake) (actual ok))
             (actual_cell (pos-r 6) (pos-c 4) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 6) (pos-c 5) (type hill) (actual ok))
             (actual_cell (pos-r 6) (pos-c 6) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 6) (pos-c 7) (type urban) (actual severe-flood ))
             (actual_cell (pos-r 6) (pos-c 8) (type lake) (actual ok))
             (actual_cell (pos-r 6) (pos-c 9) (type urban) (actual ok))
             (actual_cell (pos-r 6) (pos-c 10) (type rural) (actual ok))
             (actual_cell (pos-r 6) (pos-c 11) (type border) (actual ok))
             (actual_cell (pos-r 7) (pos-c 1) (type gate) (actual ok))
             (actual_cell (pos-r 7) (pos-c 2) (type rural) (actual ok))
             (actual_cell (pos-r 7) (pos-c 3) (type rural) (actual severe-flood ))
             (actual_cell (pos-r 7) (pos-c 4) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 7) (pos-c 5) (type rural) (actual ok))
             (actual_cell (pos-r 7) (pos-c 6) (type urban) (actual severe-flood ))
             (actual_cell (pos-r 7) (pos-c 7) (type lake) (actual ok))
             (actual_cell (pos-r 7) (pos-c 8) (type hill) (actual ok))
             (actual_cell (pos-r 7) (pos-c 9) (type urban) (actual ok))
             (actual_cell (pos-r 7) (pos-c 10) (type rural) (actual ok))
             (actual_cell (pos-r 7) (pos-c 11) (type gate) (actual ok))
             (actual_cell (pos-r 8) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 8) (pos-c 2) (type urban) (actual ok))
             (actual_cell (pos-r 8) (pos-c 3) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 8) (pos-c 4) (type urban) (actual ok))
             (actual_cell (pos-r 8) (pos-c 5) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 8) (pos-c 6) (type urban) (actual severe-flood ))
             (actual_cell (pos-r 8) (pos-c 7) (type lake) (actual ok))
             (actual_cell (pos-r 8) (pos-c 8) (type rural) (actual initial-flood ))
             (actual_cell (pos-r 8) (pos-c 9) (type hill) (actual ok))
             (actual_cell (pos-r 8) (pos-c 10) (type hill) (actual ok))
             (actual_cell (pos-r 8) (pos-c 11) (type border) (actual ok))
             (actual_cell (pos-r 9) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 9) (pos-c 2) (type urban) (actual ok))
             (actual_cell (pos-r 9) (pos-c 3) (type urban) (actual ok))
             (actual_cell (pos-r 9) (pos-c 4) (type rural) (actual ok))             (actual_cell (pos-r 9) (pos-c 5) (type rural) (actual ok))
             (actual_cell (pos-r 9) (pos-c 6) (type rural) (actual severe-flood ))
             (actual_cell (pos-r 9) (pos-c 7) (type rural) (actual severe-flood ))
             (actual_cell (pos-r 9) (pos-c 8) (type lake) (actual ok))
             (actual_cell (pos-r 9) (pos-c 9) (type hill) (actual ok))
             (actual_cell (pos-r 9) (pos-c 10) (type hill) (actual ok))
             (actual_cell (pos-r 9) (pos-c 11) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 1) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 2) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 3) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 4) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 5) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 6) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 7) (type gate) (actual ok))
             (actual_cell (pos-r 10) (pos-c 8) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 9) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 10) (type border) (actual ok))
             (actual_cell (pos-r 10) (pos-c 11) (type border) (actual ok))
             )
     (retract ?f1))
(defrule creation2
(declare (salience 24))
      (create-discovered)
      (actual_cell (pos-r ?r) (pos-c ?c) (type border|gate|hill|lake))
=>  (assert (discovered (step 0) (pos-r ?r) (pos-c ?c) (utility no) 
                        (discover no) (abstract ok) (precise ok)))
    )
(defrule creation3
(declare (salience 24))
      (create-discovered)
      (actual_cell (pos-r ?r) (pos-c ?c) (type urban|rural) (actual initial-flood))
=>  (assert (discovered (step 0) (pos-r ?r) (pos-c ?c) (utility yes) 
                        (discover no) (abstract flood)(precise initial-flood)))
    )
(defrule creation4
(declare (salience 24))
      (create-discovered)
      (actual_cell (pos-r ?r) (pos-c ?c) (type urban|rural) (actual severe-flood))
  =>  (assert (discovered (step 0) (pos-r ?r) (pos-c ?c) (utility yes) 
                        (discover no) (abstract flood)(precise severe-flood)))
      )
(defrule creation5
(declare (salience 24))
      (create-discovered)
      (actual_cell (pos-r ?r) (pos-c ?c) (type urban|rural) (actual ok))
  =>  (assert (discovered (step 0) (pos-r ?r) (pos-c ?c) (utility yes) 
                          (discover no) (abstract ok) (precise ok)))
      )
;dur-last-action deve essere trattatato in java come intero perciò di default non sarà NA ma 0
;aggiunto anche (halt) così è possibile premere step
 (defrule creation-start
 (declare (salience 23))
 ?f1 <-   (create-initial-setting)
 ?f2 <-   (create-discovered)
 =>
    (assert (status (time 0) (step 0)(result no))
            (agentstatus  (step 0) (time 0) (pos-r 1) (pos-c 5) 
                          (direction north) (dur-last-act 0))
            (penalty 0))
      (retract ?f1 ?f2)
      ;ANFALT(halt)
      (focus MAIN))
;;--------------------------------------------------------------------------------------------------------------;;   REGOLE DI go-forward
(defrule go-forward-north-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction north))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type ~border&~hill))
       => (modify ?f1 (pos-r (+ ?r 1)) (step (+ ?i 1)) 
                      (time (+ ?t 10)) (dur-last-act 10))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10))))
(defrule go-forward-north-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction north))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type border|hill))
       => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10)) (result disaster))
  (focus MAIN))
 (defrule go-forward-south-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction south))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type ~border&~hill))
       => (modify ?f1 (pos-r (- ?r 1)) (step (+ ?i 1)) 
                      (time (+ ?t 10)) (dur-last-act 10))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10))))
(defrule go-forward-south-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction south))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type border|hill))
=> (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10)) (result disaster)) 
  (focus MAIN))
(defrule go-forward-west-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction west))
        (actual_cell (pos-r ?r) (pos-c =(- ?c 1)) (type ~border&~hill))
       => (modify ?f1 (pos-c (- ?c 1)) (step (+ ?i 1)) 
                      (time (+ ?t 10)) (dur-last-act 10))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10))))
(defrule go-forward-west-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction west))
        (actual_cell (pos-r ?r) (pos-c =(- ?c 1)) (type border|hill))
       => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10)) (result disaster))
  (focus MAIN))
(defrule go-forward-east-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction east))
        (actual_cell (pos-r ?r) (pos-c =(+ ?c 1)) (type ~border&~hill))
       => (modify ?f1 (pos-c (+ ?c 1)) (step (+ ?i 1)) 
                      (time (+ ?t 10)) (dur-last-act 10))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10))))
(defrule go-forward-east-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-forward))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction east))
        (actual_cell (pos-r ?r) (pos-c =(+ ?c 1)) (type border|hill))
      => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 10)) (result disaster))
  (focus MAIN))
;;   REGOLE go-left
(defrule go-left-north-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction north))
        (actual_cell (pos-r ?r) (pos-c =(- ?c 1)) (type ~border&~hill))
       => (modify ?f1 (pos-c (- ?c 1)) (direction west)(step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))

(defrule go-left-north-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction north))
        (actual_cell (pos-r ?r) (pos-c =(- ?c 1))(type border|hill))
      => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
         (focus MAIN))
 (defrule go-left-south-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction south))
        (actual_cell (pos-r ?r) (pos-c =(+ ?c 1))  (type ~border&~hill))
       => (modify ?f1 (pos-c (+ ?c 1)) (direction east) (step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))
(defrule go-left-south-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction south))
        (actual_cell (pos-r ?r) (pos-c =(+ ?c 1)) (type border|hill))
    =>  (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
        (focus MAIN))
 (defrule go-left-west-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction west))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type ~border&~hill))
       => (modify ?f1 (pos-r (- ?r 1)) (direction south) (step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))
(defrule go-left-west-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction west))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type border|hill))
      =>(modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
        (focus MAIN))
(defrule go-left-east-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction east))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type ~border&~hill))
       => (modify ?f1 (pos-r (+ ?r 1)) (direction north) (step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))
(defrule go-left-east-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-left))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction east))        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type border|hill))
     => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
        (focus MAIN))
; regole  per go-right
(defrule go-right-north-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction north))
        (actual_cell (pos-r ?r) (pos-c =(+ ?c 1)) (type ~border&~hill))
       => (modify ?f1 (pos-c (+ ?c 1)) (direction east)(step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))
(defrule go-right-north-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction north))
        (actual_cell (pos-r ?r) (pos-c =(+ ?c 1))(type border|hill))
     => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
        (focus MAIN))
 (defrule go-right-south-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction south))
        (actual_cell (pos-r ?r) (pos-c =(- ?c 1))  (type ~border&~hill))
       => (modify ?f1 (pos-c (- ?c 1)) (direction west) (step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))
(defrule go-right-south-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction south))
        (actual_cell (pos-r ?r) (pos-c =(- ?c 1)) (type border|hill))
  =>    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
        (focus MAIN))
  (defrule go-right-west-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction west))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type ~border&~hill))
       => (modify ?f1 (pos-r (+ ?r 1)) (direction north) (step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))
(defrule go-right-west-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction west))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type border|hill))
     => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
        (focus MAIN))
(defrule go-right-east-ok 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction east))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type ~border&~hill))
       => (modify ?f1 (pos-r (- ?r 1)) (direction south) (step (+ ?i 1)) 
                      (time (+ ?t 15)) (dur-last-act 15))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15))))
(defrule go-right-east-disaster 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  go-right))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c)(direction east))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type border|hill))
     => (modify ?f2 (step (+ ?i 1)) (time (+ ?t 15)) (result disaster))
 (focus MAIN))
 ;;   REGOLE DI LOITER 
(defrule loiter 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  loiter))
  ?f1<- (agentstatus (step ?i))
       => (modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)) (dur-last-act 40))
          (modify ?f2 (step (+ ?i 1)) (time (+ ?t 40))))
;;   REGOLE DI Loiter-monitoring
(defrule loiter-monitor-1 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  loiter-monitoring))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c))
        (actual_cell (pos-r ?r) (pos-c ?c) (type hill|gate))
=>   (assert (perc-monitor (step (+ ?i 1)) (time (+ ?t 50)) (pos-r ?r)
                         (pos-c ?c) (perc other))) 
     (modify ?f1 (step (+ ?i 1)) (time (+ ?t 50)) (dur-last-act 50))
     (modify ?f2 (step (+ ?i 1)) (time (+ ?t 50))))
(defrule loiter-monitor-2 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  loiter-monitoring))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c))
        (actual_cell (pos-r ?r) (pos-c ?c) (type lake))
=>  (assert (perc-monitor (step (+ ?i 1)) (time (+ ?t 50)) (pos-r ?r)
                         (pos-c ?c) (perc deep-water))) 
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 50)) (dur-last-act 50))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 50))))
(defrule loiter-monitor-3 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  loiter-monitoring))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c))
        (actual_cell (pos-r ?r) (pos-c ?c) (type urban|rural) 
                      (actual initial-flood))
=>  (assert (perc-monitor (step (+ ?i 1)) (time (+ ?t 50)) (pos-r ?r)
                         (pos-c ?c) (perc low-water))) 
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 50)) (dur-last-act 50))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 50))))
(defrule loiter-monitor-4 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  loiter-monitoring))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c))
         (actual_cell (pos-r ?r) (pos-c ?c) (type urban|rural) 
                      (actual severe-flood))
=> (assert (perc-monitor (step (+ ?i 1)) (time (+ ?t 50)) (pos-r ?r)
                         (pos-c ?c) (perc deep-water))) 
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 50)) (dur-last-act 50))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 50))))
(defrule loiter-monitor-5 
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  loiter-monitoring))
  ?f1<- (agentstatus (step ?i)(pos-r ?r) (pos-c ?c))
        (actual_cell (pos-r ?r) (pos-c ?c) (type urban|rural) 
                      (actual ok))
=>  (assert (perc-monitor (step (+ ?i 1)) (time (+ ?t 50)) (pos-r ?r)
                         (pos-c ?c) (perc other))) 
    (modify ?f1 (step (+ ?i 1)) (time (+ ?t 50)) (dur-last-act 50))
    (modify ?f2 (step (+ ?i 1)) (time (+ ?t 50))))

;;;;******************************
;;;;******************************
;;;;          DONE 
(defrule done-undiscovered1
   (declare (salience 21))    
  ?f2<- (status (step ?i)) 
        (exec (step ?i) (action  done))
  ?f3<- (discovered (step ?i) (pos-r ?x) (pos-c ?y) (utility yes)
                        (discover no) (abstract flood))
  ?f1<- (penalty ?p)
        => (assert (penalty (+ ?p 1000000)))
           (retract ?f1 ?f3)
           )
(defrule done-undiscovered2
   (declare (salience 21)) 
  ?f2<- (status (step ?i)) 
        (exec (step ?i) (action  done))
  ?f3<- (discovered (step ?i) (pos-r ?x) (pos-c ?y) (utility yes) 
                        (discover no) (abstract ok))
  ?f1<- (penalty ?p)
        => (assert (penalty (+ ?p 100000)))
           (retract ?f1 ?f3)
)
(defrule done-no-gate
   (declare (salience 20))  
  ?f2<- (status (step ?i)) 
        (exec (step ?i) (action  done))
        (agentstatus (step ?i) (pos-r ?r) (pos-c ?c))
        (actual_cell (pos-r ?r) (pos-c ?c) (type ~gate))
  ?f1<- (penalty ?p)
        => (assert (penalty (+ ?p 2000000)))
           (retract ?f1)
          (modify ?f2 (step (+ ?i 1)) (result done))
           (focus MAIN)
)
(defrule done-in-gate
   (declare (salience 20)) 
  ?f2<- (status (step ?i)) 
        (exec (step ?i) (action  done))
        (agentstatus (time ?i) (pos-r ?r) (pos-c ?c))
        (actual_cell (pos-r ?r) (pos-c ?c) (type gate))
        => 
          (modify ?f2 (step (+ ?i 1)) (result done))
           (focus MAIN)
)
;;;;******************************
;;;;******************************
;;;;          INFORM
(defrule inform-precise-no-utility
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  inform) (param1 ?x) (param2 ?y) 
               (param3 ?actual&ok|initial-flood|severe-flood))
  ?f4<- (discovered (step ?i) (pos-r ?x) (pos-c ?y) (utility no) 
                    (precise  ?actual))
  ?f1<- (agentstatus (step ?i) (time ?t))
  ?f3<- (penalty ?p)
        => (modify  ?f1 (step (+ ?i 1))(time (+ ?t 1)) (dur-last-act 1))
           (modify  ?f2 (step (+ ?i 1))(time (+ ?t 1)))
           (modify  ?f4 (step (+ ?i 1)))
           (retract ?f3)
           (assert (penalty (+ ?p 50000)))
)
(defrule inform-precise-useful
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  inform) (param1 ?x) (param2 ?y) 
              (param3 ?actual&ok|initial-flood|severe-flood))
  ?f4<- (discovered (step ?i) (pos-r ?x) (pos-c ?y) (utility yes) 
                    (discover no|abstract) (precise ?actual))
  ?f1<- (agentstatus (step ?i) (time ?t))
        => (modify  ?f1 (step (+ ?i 1))(time (+ ?t 1)) (dur-last-act 1))
           (modify  ?f2 (step (+ ?i 1))(time (+ ?t 1)))
           (modify  ?f4 (step (+ ?i 1)) (discover yes) (utility no))
)
           
(defrule inform-precise-wrong
   (declare (salience 20))    
   ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  inform) (param1 ?x) (param2 ?y) 
               (param3 ?actual&ok|initial-flood|severe-flood))
  ?f4<- (discovered (step ?i) (pos-r ?x) (pos-c ?y)
                    (precise  ?actual1))
        (test (neq ?actual ?actual1))
  ?f1<- (agentstatus (step ?i) (time ?t))
  ?f3<- (penalty ?p)
        => (modify  ?f1 (step (+ ?i 1))(time (+ ?t 1)) (dur-last-act 1))
           (modify  ?f2 (step (+ ?i 1))(time (+ ?t 1)))
           (modify  ?f4 (step (+ ?i 1)))
           (retract ?f3)
           (assert (penalty (+ ?p 1000000)))
)
(defrule inform-abstract-useful
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  inform) (param1 ?x) (param2 ?y) (param3 flood))
  ?f4<- (discovered (step ?i) (pos-r ?x) (pos-c ?y) (utility yes) 
                    (discover no)(abstract flood))
  ?f1<- (agentstatus (step ?i) (time ?t))
        => (modify  ?f1 (step (+ ?i 1))(time (+ ?t 1)) (dur-last-act 1))
           (modify  ?f2 (step (+ ?i 1))(time (+ ?t 1)))
           (modify  ?f4 (step (+ ?i 1))(discover abstract))
)
(defrule inform-abstract-wrong
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  inform) (param1 ?x) (param2 ?y) (param3 flood))
  ?f4<- (discovered (step ?i) (pos-r ?x) (pos-c ?y) (abstract ~flood))
  ?f1<- (agentstatus (step ?i) (time ?t))
  ?f3<- (penalty ?p)
        => (modify  ?f1 (step (+ ?i 1))(time (+ ?t 1)) (dur-last-act 1))
           (modify  ?f2 (step (+ ?i 1))(time (+ ?t 1)))
           (modify  ?f4 (step (+ ?i 1)))
           (retract ?f3)
           (assert (penalty (+ ?p 1000000)))
           )
(defrule inform-abstract-repeated
   (declare (salience 20))    
  ?f2<- (status (step ?i) (time ?t)) 
        (exec (step ?i) (action  inform) (param1 ?x) (param2 ?y) (param3 flood))
  ?f4<- (discovered (step ?i) (pos-r ?x) (pos-c ?y)
                    (discover abstract|yes) (abstract flood))
?f1<- (agentstatus (step ?i) (time ?t))
?f3<-  (penalty ?p)
        => (modify  ?f1 (step (+ ?i 1))(time (+ ?t 1)) (dur-last-act 1))
           (modify  ?f2 (step (+ ?i 1))(time (+ ?t 1)))
           (modify  ?f4 (step (+ ?i 1)))
           (retract ?f3)
           (assert (penalty (+ ?p 50000)))
           )
;; **************************************************************
;; **************************************************************
;;  
;;  Regole per evoluzione temporale  di DISCOVERED e gestione penalità
;;  se non c'è stato aggiornamento allo step corrente di discovered di una cella 
;;  si aggiorna dicovered a step corrente e sulla base della durata dell'ultima 
;;  azione eseguita
;;  si aggiornano le penalità
(defrule Evolution1       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover no))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type urban) (actual severe-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 10 ?dur))))
	(retract ?f2)	
)

(defrule Evolution2       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover no))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type urban) (actual initial-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 6 ?dur))))
	(retract ?f2)	
)
(defrule Evolution3       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover no))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type rural) (actual severe-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 4 ?dur))))
	(retract ?f2)	
)
(defrule Evolution4       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover no))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type rural) (actual initial-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 2 ?dur))))
	(retract ?f2)	
)

(defrule Evolution5       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover abstract))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type urban) (actual severe-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 5 ?dur))))
	(retract ?f2)	
)
(defrule Evolution6       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover abstract))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type urban) (actual initial-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 3 ?dur))))
	(retract ?f2)	
)

(defrule Evolution7       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover abstract))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type rural) (actual severe-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 2 ?dur))))
	(retract ?f2)	
)

(defrule Evolution8       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover abstract))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type rural) (actual initial-flood))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 1 ?dur))))
	(retract ?f2)	
)
(defrule Evolution9       
	(declare (salience 10))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) (discover no))
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
        (actual_cell (pos-r ?r) (pos-c ?c) (type rural|urban) (actual ok))
        (agentstatus (step ?i) (dur-last-act ?dur))
?f2<-	(penalty ?p)
=> 
	(modify ?f1 (step ?i))
	(assert (penalty (+ ?p (* 1 ?dur))))
	(retract ?f2)	
)
(defrule Evolution10       
	(declare (salience 9))
	(status (step ?i) (time ?t))
?f1<-	(discovered (step =(- ?i 1)) (pos-r ?r) (pos-c ?c)) 
        (not (discovered (step ?i) (pos-r ?r) (pos-c ?c)))
=> 
	(modify ?f1 (step ?i))
)

;;;;******************************************
;;;;******************************************
;;;;          GENERAZIONE PERCEZIONI VISIVE
(defrule percept-north
(declare (salience 5))
  ?f1<- (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north)) 
        (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (type ?x1))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c)  (type ?x2))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (type ?x3))
        (actual_cell (pos-r ?r)  (pos-c =(- ?c 1)) (type ?x4))
        (actual_cell (pos-r ?r)  (pos-c ?c)  (type ?x5))
        (actual_cell (pos-r ?r)  (pos-c =(+ ?c 1)) (type ?x6))
        (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (type ?x7))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c)  (type ?x8))
        (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (type ?x9))
      => 
        (assert (perc-vision (time ?t) (step ?i) (pos-r ?r) (pos-c ?c)
                           (direction north) 
                           (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
                           (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
                           (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)))
)
(defrule percept-north-water1
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) 
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 1 ?i))
     => (modify ?f2 (perc1 water))
        (assert (percwater 1 ?i)))
(defrule percept-north-water2
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 2 ?i))
     => (modify ?f2 (perc2 water))
        (assert (percwater 2 ?i)))
(defrule percept-north-water3
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 3 ?i))
     => (modify ?f2 (perc3 water))
        (assert (percwater 3 ?i)))

(defrule percept-north-water4
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r ?r) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r ?r) (pos-c =(- ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 4 ?i))
     => (modify ?f2 (perc4 water))
        (assert (percwater 4 ?i)))
(defrule percept-water5
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     )
         (or (actual_cell (pos-r ?r) (pos-c ?c) (type lake))
             (actual_cell (pos-r ?r) (pos-c ?c)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 5 ?i))
     => (modify ?f2 (perc5 water))
        (assert (percwater 5 ?i)))

(defrule percept-north-water6
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r ?r) (pos-c =(+ ?c 1)) (type lake))
             (actual_cell (pos-r ?r) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 6 ?i))
     => (modify ?f2 (perc6 water))
        (assert (percwater 6 ?i)))
 
(defrule percept-north-water7
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) 
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 7 ?i))
     => (modify ?f2 (perc7 water))
        (assert (percwater 7 ?i)))
(defrule percept-north-water8
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c ?c)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 8 ?i))
     => (modify ?f2 (perc8 water))
        (assert (percwater 8 ?i)))
(defrule percept-north-water9
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 9 ?i))
     => (modify ?f2 (perc9 water))
        (assert (percwater 9 ?i)))

(defrule percept-south
(declare (salience 5))
  ?f1<- (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south)) 
        (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (type ?x1))
        (actual_cell (pos-r =(- ?r 1)) (pos-c ?c)  (type ?x2))
        (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (type ?x3))
        (actual_cell (pos-r ?r)  (pos-c =(+ ?c 1)) (type ?x4))
        (actual_cell (pos-r ?r)  (pos-c ?c)  (type ?x5))
        (actual_cell (pos-r ?r)  (pos-c =(- ?c 1)) (type ?x6))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (type ?x7))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c)  (type ?x8))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (type ?x9))
      => 
        (assert (perc-vision (time ?t) (step ?i) (pos-r ?r) (pos-c ?c)
                           (direction south) 
                           (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
                           (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
                           (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)))
       )
(defrule percept-south-water1
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1))  (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 1 ?i))
     => (modify ?f2 (perc1 water))
        (assert (percwater 1 ?i)))

(defrule percept-south-water2
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c ?c) (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c ?c)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 2 ?i))
     => (modify ?f2 (perc2 water))
        (assert (percwater 2 ?i)))

(defrule percept-south-water3
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 3 ?i))
     => (modify ?f2 (perc3 water))
        (assert (percwater 3 ?i)))

(defrule percept-south-water4
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south))
         (or (actual_cell (pos-r ?r) (pos-c =(+ ?c 1)) (type lake))
             (actual_cell (pos-r ?r) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 4 ?i))
     => (modify ?f2 (perc4 water))
        (assert (percwater 4 ?i)))
 
(defrule percept-south-water6
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south))
         (or (actual_cell (pos-r ?r) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r ?r) (pos-c =(- ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 6 ?i))
     => (modify ?f2 (perc6 water))
        (assert (percwater 6 ?i)))

(defrule percept-south-water7
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) 
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 7 ?i))
     => (modify ?f2 (perc7 water))
        (assert (percwater 7 ?i)))

(defrule percept-south-water8
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction north))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c ?c)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 8 ?i))
     => (modify ?f2 (perc8 water))
        (assert (percwater 8 ?i)))

(defrule percept-south-water9
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction south))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 9 ?i))
     => (modify ?f2 (perc9 water))
        (assert (percwater 9 ?i)))

(defrule percept-east
(declare (salience 5))
  ?f1<- (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east)) 
        (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (type ?x1))
        (actual_cell (pos-c =(+ ?c 1)) (pos-r ?r)  (type ?x2))
        (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (type ?x3))
        (actual_cell (pos-c ?c)  (pos-r =(+ ?r 1)) (type ?x4))
        (actual_cell (pos-r ?c)  (pos-c ?r)  (type ?x5))
        (actual_cell (pos-c ?c)  (pos-r =(- ?r 1)) (type ?x6))
        (actual_cell (pos-c =(- ?c 1)) (pos-r =(+ ?r 1)) (type ?x7))
        (actual_cell (pos-c =(- ?c 1)) (pos-r ?r)  (type ?x8))
        (actual_cell (pos-c =(- ?c 1)) (pos-r =(- ?r 1)) (type ?x9))
      => 
        (assert (perc-vision (time ?t) (step ?i) (pos-r ?r) (pos-c ?c)
                           (direction east) 
                           (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
                           (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
                           (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)))
       )
(defrule percept-east-water1
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 1 ?i))
     => (modify ?f2 (perc1 water))
        (assert (percwater 1 ?i)))

(defrule percept-east-water2
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-c =(+ ?c 1)) (pos-r ?r) (type lake))
             (actual_cell (pos-c =(+ ?c 1)) (pos-r ?r)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 2 ?i))
     => (modify ?f2 (perc2 water))
        (assert (percwater 2 ?i)))
(defrule percept-east-water3
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1))  (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 3 ?i))
     => (modify ?f2 (perc3 water))
        (assert (percwater 3 ?i)))

(defrule percept-east-water4
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-c ?c)  (pos-r =(+ ?r 1)) (type lake))
             (actual_cell (pos-c ?c)  (pos-r =(+ ?r 1)) (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 4 ?i))
     => (modify ?f2 (perc4 water))
        (assert (percwater 4 ?i)))
(defrule percept-east-water6
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-c ?c) (pos-r =(- ?r 1)) (type lake))
             (actual_cell (pos-c ?c) (pos-r =(- ?r 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 6 ?i))
     => (modify ?f2 (perc6 water))
        (assert (percwater 6 ?i)))
 
(defrule percept-east-water7
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-c =(- ?c 1)) (pos-r =(+ ?r 1)) (type lake))
             (actual_cell (pos-c =(- ?c 1)) (pos-r =(+ ?r 1))  
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 7 ?i))
     => (modify ?f2 (perc7 water))
        (assert (percwater 7 ?i)))

(defrule percept-east-water8
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-c =(- ?c 1)) (pos-r ?r) (type lake))
             (actual_cell (pos-c =(- ?c 1)) (pos-r ?r)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 8 ?i))
     => (modify ?f2 (perc8 water))
        (assert (percwater 8 ?i)))
(defrule percept-east-water9
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction east))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 9 ?i))
     => (modify ?f2 (perc9 water))
        (assert (percwater 9 ?i)))

(defrule percept-west
(declare (salience 5))
  ?f1<- (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west)) 
        (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (type ?x1))
        (actual_cell (pos-c =(- ?c 1)) (pos-r ?r)  (type ?x2))
        (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (type ?x3))
        (actual_cell (pos-c ?c)  (pos-r =(- ?r 1)) (type ?x4))
        (actual_cell (pos-r ?c)  (pos-c ?r)  (type ?x5))
        (actual_cell (pos-c ?c)  (pos-r =(+ ?r 1)) (type ?x6))
        (actual_cell (pos-c =(+ ?c 1)) (pos-r =(- ?r 1)) (type ?x7))
        (actual_cell (pos-c =(+ ?c 1)) (pos-r ?r)  (type ?x8))
        (actual_cell (pos-c =(+ ?c 1)) (pos-r =(+ ?r 1)) (type ?x9))
      => 
        (assert (perc-vision (time ?t) (step ?i) (pos-r ?r) (pos-c ?c)
                           (direction west) 
                           (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
                           (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
                           (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)))
       )
(defrule percept-west-water1
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (type lake))
             (actual_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 1 ?i))
     => (modify ?f2 (perc1 water))
        (assert (percwater 1 ?i)))

(defrule percept-west-water2
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-c =(- ?c 1)) (pos-r ?r) (type lake))
             (actual_cell (pos-c =(- ?c 1)) (pos-r ?r)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 2 ?i))
     => (modify ?f2 (perc2 water))
        (assert (percwater 2 ?i)))

(defrule percept-west-water3
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))  (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 3 ?i))
     => (modify ?f2 (perc3 water))
        (assert (percwater 3 ?i)))

(defrule percept-west-water4
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-c ?c)  (pos-r =(- ?r 1)) (type lake))
             (actual_cell (pos-c ?c)  (pos-r =(- ?r 1)) (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 4 ?i))
     => (modify ?f2 (perc4 water))
        (assert (percwater 4 ?i)))
 
(defrule percept-west-water6
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-c ?c) (pos-r =(+ ?r 1)) (type lake))
             (actual_cell (pos-c ?c) (pos-r =(+ ?r 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 6 ?i))
     => (modify ?f2 (perc6 water))
        (assert (percwater 6 ?i)))
(defrule percept-west-water7
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-c =(+ ?c 1)) (pos-r =(- ?r 1)) (type lake))
             (actual_cell (pos-c =(+ ?c 1)) (pos-r =(- ?r 1))  
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 7 ?i))
     => (modify ?f2 (perc7 water))
        (assert (percwater 7 ?i)))
(defrule percept-west-water8
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-c =(+ ?c 1)) (pos-r ?r) (type lake))
             (actual_cell (pos-c =(+ ?c 1)) (pos-r ?r)
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 8 ?i))
     => (modify ?f2 (perc8 water))
        (assert (percwater 8 ?i)))

(defrule percept-west-water9
(declare (salience 4))
         (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) 
                     (direction west))
         (or (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (type lake))
             (actual_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1))
                          (type rural|urban) 
                          (actual initial-flood|severe-flood)))
  ?f2<- (perc-vision (step ?i))
        (not (percwater 9 ?i))
     => (modify ?f2 (perc9 water))
        (assert (percwater 9 ?i)))
(defrule perc-vision-done
(declare (salience 3))
    (status (time ?t))
     => 
		;ANFALT(halt) ;;aggiunta per poter usare la Step
        (focus MAIN))

;;;;;   REGOLE MINIMALI PER IL FUNZIONAMENTO DELL'AGENTE
;;;;;   Ad ogni istante utente umano deve fornire indicazione sulla regola da eseguire tramite
;;;;;   apposita assert
(defmodule AGENT (import MAIN ?ALL))
(deftemplate kagent (slot time) (slot step) (slot pos-r) (slot pos-c) 
                    (slot direction))
;	DA COMPLETARE E CORREGGERE(VEDI PEZ DROPBOX)
;(deftemplate kagent_cell (slot pos-r) (slot pos-c)
;	(slot percepted) (slot visited)
;	(slot inform (allowedvalues (no ok ))


(defrule  beginagent
    (declare (salience 10))
    (status (step 0))
    (not (exec (step 0)))
  => 
    (assert (kagent (time 0) (step 0)
                           (pos-r 1) (pos-c 5) (direction north)))
    )

;; COMMENTATO PER VEDERLO NELL'INTERFACCIA
;;(defrule ask_act
;; ?f <-   (status (step ?i))
;;    =>  (printout t crlf crlf)
;;        (printout t "action to be executed at step:" ?i)
;;        (printout t crlf crlf)
;;        (modify ?f (result no)))

(defrule exec_act
    (status (step ?i))
    (exec (step ?i))
 => (focus MAIN))


; Nel seguito viene riportata una semplice sequenza di comandi che dovrebbe
; servire a verificare il comportamento del modulo ENV nel dominio descritto 
; nel file precedente.
; non tutte le azioni sono utili in vista di una esplorazione, ma sono state 
; inserite per verificare il comportamento del modulo ENV che deve segnalare
; esito non nominale di alcune azioni
;(assert (exec (action go-forward) (step 0)))
;(assert (exec (action go-forward) (step 1)))
;(assert (exec (action go-forward) (step 2)))
;(assert (exec (action go-forward) (step  3))) 
;(assert (exec (action inform) (param1 6) (param2 6) (param3 flood) (step 4)))
;(assert (exec (action go-left) (step 5)))
;(assert (exec (action inform) (param1 4) (param2 3) (param3 flood) (step 6)))
;(assert (exec (action inform) (param1 5) (param2 4) (param3 flood) (step 7)))
;(assert (exec (action inform) (param1 4) (param2 4) (param3 flood) (step 8)))
;(assert (exec (action inform) (param1 4) (param2 4) (param3 ok) (step 9)))
;(assert (exec (action go-forward) (step 10)))
;(assert (exec (action go-left) (step 11)))
;(assert (exec (action loiter-monitoring) (step 12)))
;(assert (exec (action inform) (param1 4) (param2 3) (param3 initial-flood) (step 13)))
;(assert (exec (action go-forward) (step  14))) 
;(assert (exec (action loiter-monitoring) (step 15)))
;(assert (exec (action inform) (param1 3) (param2 3) (param3 initial-flood) (step 16)))
;(assert (exec (action go-right) (step 17)))
;(assert (exec (action inform) (param1 2) (param2 3) (param3 flood) (step 18)))
;(assert (exec (action inform) (param1 2) (param2 2) (param3 flood) (step 19)))
;(assert (exec (action go-right) (step 20)))
;(assert (exec (action go-forward) (step  21))) 
;(assert (exec (action go-forward) (step  22))) 
;(assert (exec (action inform) (param1 6) (param2 2) (param3 flood) (step 23)))
;(assert (exec (action go-forward) (step  24))) 
;(assert (exec (action go-right) (step 25)))
;(assert (exec (action inform) (param1 7) (param2 2) (param3 ok) (step 26)))
;(assert (exec (action inform) (param1 8) (param2 2) (param3 ok) (step 27)))
;(assert (exec (action inform) (param1 8) (param2 3) (param3 flood) (step 28)))
;(assert (exec (action inform) (param1 7) (param2 3) (param3 flood) (step 29)))
;(assert (exec (action inform) (param1 6) (param2 4) (param3 flood) (step 30)))
;(assert (exec (action inform) (param1 7) (param2 4) (param3 flood) (step 31)))
;(assert (exec (action inform) (param1 8) (param2 4) (param3 ok) (step 32)))
;(assert (exec (action go-forward) (step  33)))
;(assert (exec (action inform) (param1 8) (param2 5) (param3 flood) (step 34)))
;(assert (exec (action inform) (param1 7) (param2 5) (param3 ok) (step 35)))
;(assert (exec (action inform) (param1 6) (param2 5) (param3 ok) (step 36)))
;(assert (exec (action go-forward) (step  37)))
;(assert (exec (action inform) (param1 8) (param2 6) (param3 flood) (step 38)))
;(assert (exec (action inform) (param1 7) (param2 6) (param3 flood) (step 39)))
;(assert (exec (action go-forward) (step  40)))	
;(assert (exec (action loiter-monitoring) (step 41)))
;(assert (exec (action inform) (param1 7) (param2 6) (param3 severe-flood) (step 42)))	

(defrule turno0
 ?f <-   (status (step 0))
    =>  (printout t crlf crlf)
        (printout t "aziono 0")
        (printout t crlf)
        (assert (exec (action go-forward) (step 0)))
)
        
(defrule turno1
 ?f <-   (status (step 1))
    =>  (printout t crlf crlf)
        (printout t "aziono 1")
        (printout t crlf)
        (assert (exec (action go-forward) (step 1)))
)
        
(defrule turno2
 ?f <-   (status (step 2))
    =>  (printout t crlf crlf)
        (printout t "aziono 2")
        (printout t crlf)
        (assert (exec (action go-forward) (step 2)))
)
        
(defrule turno3
 ?f <-   (status (step 3))
    =>  (printout t crlf crlf)
        (printout t "aziono 3")
        (printout t crlf)
        (assert (exec (action go-forward) (step 3)))
)

(defrule turno4
 ?f <-   (status (step 4))
     => (printout t crlf crlf)
        (printout t "aziono 4")
        (printout t crlf)
		(assert (exec (action inform) (param1 6) (param2 6) (param3 flood) (step 4)))
)

(defrule turno5
 ?f <-   (status (step 5))
    =>  (printout t crlf crlf)
        (printout t "aziono 5")
        (printout t crlf)
        (assert (exec (action go-left) (step 5))))


(defrule turno6
 ?f <-   (status (step 6))
    =>  (printout t crlf crlf)
        (printout t "aziono 6")
        (printout t crlf crlf)
        (assert (exec (action inform) (param1 4) (param2 3) (param3 flood) (step 6))))

(defrule turno7
 ?f <-   (status (step 7))
    =>  (printout t crlf crlf)
        (printout t "aziono 7")
        (printout t crlf crlf)
        (assert (exec (action inform) (param1 5) (param2 4) (param3 flood) (step 7))))

(defrule turno8
 ?f <-   (status (step 8))
    =>  (printout t crlf crlf)
        (printout t "aziono 8")
        (printout t crlf crlf)
        (assert (exec (action inform) (param1 4) (param2 4) (param3 flood) (step 8))))

(defrule turno9   ?f <-   (status (step 9))      =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 4) (param2 4) (param3 ok) (step 9))))
(defrule turno10  ?f <-   (status (step 10))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step 10))))
(defrule turno11  ?f <-   (status (step 11))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-left) (step 11))))
(defrule turno12  ?f <-   (status (step 12))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action loiter-monitoring) (step 12))))
(defrule turno13  ?f <-   (status (step 13))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 4) (param2 3) (param3 initial-flood) (step 13))))
(defrule turno14  ?f <-   (status (step 14))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  14))))

(defrule turno15  ?f <-   (status (step 15))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action loiter-monitoring) (step 15))))
(defrule turno16  ?f <-   (status (step 16))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 3) (param2 3) (param3 initial-flood) (step 16))))
(defrule turno17  ?f <-   (status (step 17))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-right) (step 17))))
(defrule turno18  ?f <-   (status (step 18))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 2) (param2 3) (param3 flood) (step 18))))
(defrule turno19  ?f <-   (status (step 19))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 2) (param2 2) (param3 flood) (step 19))))
(defrule turno20  ?f <-   (status (step 20))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-right) (step 20))))
(defrule turno21  ?f <-   (status (step 21))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  21))))
(defrule turno22  ?f <-   (status (step 22))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  22))))
(defrule turno23  ?f <-   (status (step 23))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 6) (param2 2) (param3 flood) (step 23))))
(defrule turno24  ?f <-   (status (step 24))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  24))))
(defrule turno25  ?f <-   (status (step 25))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-right) (step 25))))
(defrule turno26  ?f <-   (status (step 26))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 7) (param2 2) (param3 ok) (step 26))))
(defrule turno27  ?f <-   (status (step 27))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 8) (param2 2) (param3 ok) (step 27))))
(defrule turno28  ?f <-   (status (step 28))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 8) (param2 3) (param3 flood) (step 28))))
(defrule turno29  ?f <-   (status (step 29))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 7) (param2 3) (param3 flood) (step 29))))
(defrule turno30  ?f <-   (status (step 30))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 6) (param2 4) (param3 flood) (step 30))))
(defrule turno31  ?f <-   (status (step 31))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 7) (param2 4) (param3 flood) (step 31))))
(defrule turno32  ?f <-   (status (step 32))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 8) (param2 4) (param3 ok) (step 32))))
(defrule turno33  ?f <-   (status (step 33))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  33))))
(defrule turno34  ?f <-   (status (step 34))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 8) (param2 5) (param3 flood) (step 34))))
(defrule turno35  ?f <-   (status (step 35))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 7) (param2 5) (param3 ok) (step 35))))
(defrule turno36  ?f <-   (status (step 36))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 6) (param2 5) (param3 ok) (step 36))))
(defrule turno37  ?f <-   (status (step 37))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  37))))
(defrule turno38  ?f <-   (status (step 38))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 8) (param2 6) (param3 flood) (step 38))))
(defrule turno39  ?f <-   (status (step 39))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 7) (param2 6) (param3 flood) (step 39))))
(defrule turno40  ?f <-   (status (step 40))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  40))))
(defrule turno41  ?f <-   (status (step 41))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action loiter-monitoring) (step 41))))
(defrule turno42  ?f <-   (status (step 42))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action inform) (param1 7) (param2 6) (param3 severe-flood) (step 42))))
(defrule turno43  ?f <-   (status (step 43))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  43))))
(defrule turno44  ?f <-   (status (step 44))     =>  (printout t crlf crlf)         (printout t crlf crlf)(assert (exec (action go-forward) (step  44))))
