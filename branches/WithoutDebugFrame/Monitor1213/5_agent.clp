;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;; 			   			MODULO AGENT					   ;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule AGENT (import MAIN ?ALL) (export ?ALL))

(deftemplate kagent 
	(slot time) (slot step)
	(slot pos-r) (slot pos-c) 
    (slot direction)
)

(deftemplate kagent_cell 
	(slot pos-r) (slot pos-c)
	(slot type (allowed-values urban rural lake hill gate border))
	(slot percepted (allowed-values no water border gate hill urban rural)(default no))
	(slot visited (allowed-values true false)(default false)) ;//~ 	indica se ci sono effettivamente passato sopra
	(slot monitored (allowed-values no other low-water deep-water)(default no))
	(slot utility)
	(slot informed (allowed-values no ok flood initial-flood severe-flood)(default no))
)

;//~ ; rappresenta la percezione locale (ad ogni passo) dell'agente in termini delle 9 celle che e' in grado
;//~ ; di osservare: ogni campo e' rappresentato da 2 valori, riga e colonna 
;//~ ; -> es. (local_perc (p 1) (r 5) (c 4)) cioe' cella 1 di riga 5 e colonna 4
(deftemplate local_perc 
	(slot p)
	(slot r)
	(slot c)
)

;//~ template che rappresenta un passo di un piano
(deftemplate way_point
	(slot plan-id)
	(slot plan-step) (slot plan-time)
	(slot plan-pos-r) (slot plan-pos-c)
	(slot plan-direction)
	(slot plan-action)
)

;//~ template che rappresenta un goal per l'agente (attualmente cosideriamo solo goal-gate) 
(deftemplate goal
	(slot goal-id)
	(slot goal-r) (slot goal-c) 
	(slot goal-direction)
	(slot goal-time (default 99999)) (slot goal-steps)
	(slot goal-status (allowed-values NA found failed) (default NA))
)

;//~ regola che implementa la prima azione dell'agente:
;//~ attualmente iniziamo con una pianificazione multi A* verso tutti i gate
(defrule  beginagent
	(declare (salience 10))
    (status (step 0))
    (not (exec (step 0)))
    (initial_agentstatus (pos-r ?r) (pos-c ?c) (direction ?d))
 => 
    (assert 
		(kagent (time 0) (step 0) (pos-r ?r) (pos-c ?c) (direction ?d))
		
		(planning) ;//~ fatto che indica che siamo in fase di pianificazione delle possibili vie di fuga
;//~ 		(getaway) ;//~ fatto che indica che siamo in fase di fuga

		(current_goal 0) ;//~ indice del goal-gate su cui dobbiamo fare A*
		(current_best_goal 0) ;//~ indice del goal-gate piu' vicino all'agente
		(reachable_goals 0) ;//~ conta quanti goal-gate sono raggiungibili attualmente 
		(plan_counter 0) ;//~ conta quanti piani verso i goal-gate sono stati eseguiti attualmente
 						 ;//~ (indica su quanti goal-gate di quelli raggiungibili e' stata correntemente applicata A*)
		
;//~ 		(current_plan_step 0) ;//~ indice del passo del piano (di fuga) da compiere
	)
)

(defrule first-step
	(status (step 0))
	(not (exec (step 0)))
	(goal (goal-id ?gid) (goal-status found))
	(kagent (time 0) (step 0))
 =>
	(assert (exec (action go-forward) (step 0)))
)

(defrule continue-planning
	(declare (salience 9))
	(not (planning))
	(goal (goal-id ?gid) (goal-status NA))
	?c <- (current_goal ?cg)
 =>
	(assert 
		(current_goal (+ ?cg 1))
		(planning)
	)
	(retract ?c)
)

;//~ (defrule exec-plan
;//~ 	(declare (salience 9))
;//~ 	(not (planning))
;//~ 	(getaway)
;//~ 	(current_best_goal ?gid)
;//~     (goal (goal-id ?gid) (goal-status found))
;//~ 	(status (step ?s))
;//~ 	(current_plan_step ?cps)
;//~ 	?wp <- (way_point
;//~ 				(plan-id ?gid)
;//~ 				(plan-step ?cps) (plan-time ?pt)
;//~ 				(plan-pos-r ?pr) (plan-pos-c ?pc)
;//~ 				(plan-direction ?pd) (plan-action ?pa)
;//~ 			)
;//~ 	(kagent
;//~ 		(time ?t) (step ?s)
;//~ 		(pos-r ?r) (pos-c ?c)
;//~ 		(direction ?d)
;//~ 	)
;//~  =>
;//~ ;//~ 		(halt)
;//~ 	(assert (exec (step ?s) (action ?pa)))
;//~ 	(retract ?wp)
;//~ )

(defrule exec-act-getaway
	(status (step ?i))
    (exec (step ?i))
    (getaway)
    ?c <- (current_plan_step ?cps)
 => 
	(assert (current_plan_step (+ ?cps 1)))
	(retract ?c)
	(focus MAIN)
)

(defrule exec-act
	(status (step ?i))
    (exec (step ?i))
    (not (getaway))
 => 
	(focus MAIN)
)

(defrule create-kagent_cell
	(declare (salience 51))
	(prior_cell (pos-r ?r) (pos-c ?c) (type ?t))
 =>
	(assert (kagent_cell (pos-r ?r) (pos-c ?c) (type ?t)))
)

(defrule find-gates-south
	(kagent_cell (pos-r 1) (pos-c ?c) (type gate))
	(kagent_cell (pos-r 1) (pos-c =(- ?c 1)) (type border|gate))
	(kagent_cell (pos-r 1) (pos-c =(+ ?c 1)) (type border|gate))
	?p <- (plan_counter ?pc)
	(not (goal (goal-r 1) (goal-c ?c) (goal-direction south)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r 1) (goal-c ?c)
			(goal-direction south)
		)
		(plan_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule find-gates-north
	(kagent_cell (pos-r ?r&:(neq ?r 1)) (pos-c ?c) (type gate))
	(kagent_cell (pos-r ?r&:(neq ?r 1)) (pos-c =(- ?c 1)) (type border|gate))
	(kagent_cell (pos-r ?r&:(neq ?r 1)) (pos-c =(+ ?c 1)) (type border|gate))
	?p <- (plan_counter ?pc)
	(not (goal (goal-r ?r) (goal-c ?c) (goal-direction north)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r ?r) (goal-c ?c)
			(goal-direction north)
		)
		(plan_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule find-gates-west
	(kagent_cell (pos-r ?r) (pos-c 1) (type gate))
	(kagent_cell (pos-r =(- ?r 1)) (pos-c 1) (type border|gate))
	(kagent_cell (pos-r =(+ ?r 1)) (pos-c 1) (type border|gate))
	?p <- (plan_counter ?pc)
	(not (goal (goal-r ?r) (goal-c 1) (goal-direction west)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r ?r) (goal-c 1)
			(goal-direction west)
		)
		(plan_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule find-gates-east
	(kagent_cell (pos-r ?r) (pos-c ?c&:(neq ?c 1)) (type gate))
	(kagent_cell (pos-r =(- ?r 1)) (pos-c ?c&:(neq ?c 1)) (type border|gate))
	(kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c&:(neq ?c 1)) (type border|gate))
	?p <- (plan_counter ?pc)
	(not (goal (goal-r ?r) (goal-c ?c) (goal-direction east)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r ?r) (goal-c ?c)
			(goal-direction east)
		)
		(plan_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule find-best-gate
	(declare (salience 9))
	(not (planning))
	?cbg <- (current_best_goal ?gid1)
	(goal
		(goal-id ?gid1)
		(goal-steps ?gs1)
		(goal-time ?gt1)
	)
	(goal
		(goal-id ?gid2&:(neq ?gid2 ?gid1))
		(goal-steps ?gs2)
		(goal-time ?gt2&:(< ?gt2 ?gt1))
	)
 =>
	(assert (current_best_goal ?gid2))
	(retract ?cbg)
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;; PARTE DI PERC-AGENT ;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;//~ ;;;;;;;	si fa la retract di perc-vision perché altrimenti andiamo in loop infinito,
;//~ ;;;;;;; questo perche' viene attivata nuovamente perc-agent-...
;//~ 
;//~ ;;;;;;; NB perc-monitor ancora da trattare !!!!!!!!!!!!
;//~ 
;//~ ;;;;;;; cancelliamo perc-vision e non la interpretiamo perche' 
;//~ ;;;;;;; inform e loiter non aggiungono conoscenza utile
;//~ (defrule no-perc-agent
;//~ 	(declare (salience 11))
;//~ 	?pv <- (perc-vision (step ?i))
;//~ 	(exec (step =(- ?i 1)) (action inform|loiter|loiter-monitoring))
;//~  =>
;//~ 	(retract ?pv)
;//~ )

(defrule plan-delete-local-perc
	(status (step ?i))
	(current_plan_step ?i)
	(perc-vision (step ?i))
	?p1 <- (local_perc (p 1))
	?p2 <- (local_perc (p 2) (r ?r) (c ?c))
	?p3 <- (local_perc (p 3))
	?p4 <- (local_perc (p 4))
	?p5 <- (local_perc (p 5))
	?p6 <- (local_perc (p 6))
	?p7 <- (local_perc (p 7))
	?p8 <- (local_perc (p 8))
	?p9 <- (local_perc (p 9))
 =>
	(retract ?p1 ?p2 ?p3 ?p4 ?p5 ?p6 ?p7 ?p8 ?p9)
)

(defrule perc-agent-north
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction north)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1	<- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
	?f2 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f3 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
	?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
	?f6 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
	?f7 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f8 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f9 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction north))
	(assert 
		(local_perc (p 1) (r =(+ ?r 1)) (c =(- ?c 1)))
		(local_perc (p 2) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 3) (r =(+ ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 4) (r ?r) (c =(- ?c 1)))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 7) (r =(- ?r 1)) (c =(- ?c 1)))
		(local_perc (p 8) (r =(- ?r 1)) (c ?c))
		(local_perc (p 9) (r =(- ?r 1)) (c =(+ ?c 1)))
	)
	(retract ?pv)
)

(defrule perc-agent-south
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction south)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f2 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f3 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
    ?f4 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
    ?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
    ?f6 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
    ?f7 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
    ?f8 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f9 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction south))
	(assert 
		(local_perc (p 1) (r =(- ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 2) (r =(- ?r 1)) (c ?c))
		(local_perc (p 3) (r =(- ?r 1)) (c =(- ?c 1)))
		(local_perc (p 4) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r ?r) (c =(- ?c 1)))
		(local_perc (p 7) (r =(+ ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 8) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 9) (r =(+ ?r 1)) (c =(- ?c 1)))
	)
	(retract ?pv)	
)

(defrule perc-agent-east
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction east)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f2 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
    ?f3 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    ?f4 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
    ?f6 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f7 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
    ?f8 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
    ?f9 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction east))
	(assert 
		(local_perc (p 1) (r =(+ ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 2) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 3) (r =(- ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 4) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r =(- ?r 1)) (c ?c))
		(local_perc (p 7) (r =(+ ?r 1)) (c =(- ?c 1)))
		(local_perc (p 8) (r ?r) (c =(- ?c 1)))
		(local_perc (p 9) (r =(- ?r 1)) (c =(- ?c 1)))
	)
	(retract ?pv)	
)

(defrule perc-agent-west
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction west)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f2 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
    ?f3 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
    ?f4 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
    ?f6 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f7 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    ?f8 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
    ?f9 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction west))
	(assert 
		(local_perc (p 1) (r =(- ?r 1)) (c =(- ?c 1)))
		(local_perc (p 2) (r ?r) (c =(- ?c 1)))
		(local_perc (p 3) (r =(+ ?r 1)) (c =(- ?c 1)))
		(local_perc (p 4) (r =(- ?r 1)) (c ?c))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 7) (r =(- ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 8) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 9) (r =(+ ?r 1)) (c =(+ ?c 1)))
	)
	(retract ?pv)
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;; PARTE DI PERC-MONITOR ;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule perc-agent-monitored
	(declare (salience 10))
	?pm <- (perc-monitor
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(perc ?p)
	)
	?f <- (kagent_cell (pos-r ?r) (pos-c ?c))
 =>
	(modify ?f (monitored ?p))
	(retract ?pm)
)


;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;; MOVIMENTI 0.4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ; faccio un movimento solo se la cella in cui voglio andare
;//~ ; non e' border, hill
;//~ 
;//~ ; mi muovo anche se non l'ho gia' visitata
;//~ ; non attivo le regole in caso di (gateway)
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule move-forward
	(status (step ?i))
	?p1 <- (local_perc (p 1))
	?p2 <- (local_perc (p 2) (r ?r) (c ?c))
	?p3 <- (local_perc (p 3))
	?p4 <- (local_perc (p 4))
	?p5 <- (local_perc (p 5))
	?p6 <- (local_perc (p 6))
	?p7 <- (local_perc (p 7))
	?p8 <- (local_perc (p 8))
	?p9 <- (local_perc (p 9))
	(not (kagent_cell (pos-r ?r) (pos-c ?c) (type hill|border)))
	(not (kagent_cell (pos-r ?r) (pos-c ?c) (visited true)))
	(not (getaway))
 =>  
	(retract ?p1 ?p2 ?p3 ?p4 ?p5 ?p6 ?p7 ?p8 ?p9)
	(assert (exec (action go-forward) (step ?i)))
)

(defrule move-right
	(status (step ?i))
	?p1 <- (local_perc (p 1))
	?p2 <- (local_perc (p 2))
	?p3 <- (local_perc (p 3))
	?p4 <- (local_perc (p 4))
	?p5 <- (local_perc (p 5))
	?p6 <- (local_perc (p 6) (r ?r) (c ?c))
	?p7 <- (local_perc (p 7))
	?p8 <- (local_perc (p 8))
	?p9 <- (local_perc (p 9))
	(not (kagent_cell (pos-r ?r) (pos-c ?c) (type hill|border)))
	(not (kagent_cell (pos-r ?r) (pos-c ?c) (visited true)))
	(not (getaway))
 =>  
	(retract ?p1 ?p2 ?p3 ?p4 ?p5 ?p6 ?p7 ?p8 ?p9)
	(assert (exec (action go-right) (step ?i)))
)

(defrule move-left
	(status (step ?i))
	?p1 <- (local_perc (p 1))
	?p2 <- (local_perc (p 2))
	?p3 <- (local_perc (p 3))
	?p4 <- (local_perc (p 4) (r ?r) (c ?c))
	?p5 <- (local_perc (p 5))
	?p6 <- (local_perc (p 6))
	?p7 <- (local_perc (p 7))
	?p8 <- (local_perc (p 8))
	?p9 <- (local_perc (p 9))
	(not (kagent_cell (pos-r ?r) (pos-c ?c) (type hill|border)))
	(not (kagent_cell (pos-r ?r) (pos-c ?c) (visited true)))
	(not (getaway))
 => 
	(retract ?p1 ?p2 ?p3 ?p4 ?p5 ?p6 ?p7 ?p8 ?p9)
	(assert (exec (action go-left) (step ?i)))
)

(defrule inform-water
	(declare (salience 1))
	(status (step ?i))
	(local_perc (r ?r) (c ?c))
	?ka <- (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural) (percepted water) (monitored no) (informed no))
	(not (getaway))
 =>
	(assert (exec (action inform) (param1 ?r) (param2 ?c) (param3 flood) (step ?i)))
	(modify ?ka (informed flood))
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;; PARTE DI ASTAR ;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;//~ ;;;;;;;con questa regola mi sposto in planner per fare la pianificazione con A*
(defrule init-planner
	(planning)
 =>
	(focus PLANNER)
)

(defmodule PLANNER (import AGENT ?ALL) (export ?ALL))

(deftemplate kagent_node
	(slot ident) (slot open)
	(slot pos-r) (slot pos-c)
	(slot direction)
	(slot fcost) (slot gcost)
	(slot father)	
)

(deftemplate kagent_newnode
	(slot ident) 
	(slot pos-r) (slot pos-c)
	(slot direction)
	(slot fcost) (slot gcost)
	(slot father) 
)

(deftemplate plan_local_pos
	(slot p)
	(slot r)
	(slot c)
)

(defrule start-planner
	(planning)
	(kagent 
		(time ?t) (step ?s)
		(pos-r ?r) (pos-c ?c)
		(direction ?d)
	)
 =>
	(assert
		(kagent_node
			(ident 0) (open yes)
			(pos-r ?r) (pos-c ?c)
			(direction ?d)
			(fcost 0) (gcost 0)
			(father NA)
		)
		(current_node 0)
		(lastnode 0)
		(open-worse 0)
		(open-better 0)
		(alreadyclosed 0)
		(numberofnodes 0)
	)
)

(defrule achieved-goal
	(declare (salience 100))
	(planning)
    (current_node ?id)
    (current_goal ?gid)
    ?rg <- (reachable_goals ?rgls)
    ?gl <- (goal
				(goal-id ?gid)
				(goal-r ?gr) (goal-c ?gc)
				(goal-direction ?gd)
			)
    (kagent_node (ident ?id) (pos-r ?gr) (pos-c ?gc) (direction ?gd) (gcost ?g))  
 =>
	(printout t " Esiste soluzione per goal (" ?gr "," ?gc ", " ?gd ") con costo "  ?g crlf)
	(assert (solution_steps 0))
    (assert (stampa ?id))
    (assert (reachable_goals (+ ?rgls 1)))
    (retract ?rg)
    (modify ?gl (goal-status found) (goal-time ?g))
)

;//~ Aggiunto nella kagent_exec il riferimento sia alla direzione precedente che
;//~ alla direzione nuova: e' indispensabile per fare la stampa
;//~ 
;//~ Aggiunto attributo solution_steps al fatto move, per poter riordinare la
;//~ sequenza di azioni nel passaggio da PLANNER ad AGENT
(defrule stampa-sol
	(declare (salience 101))
	(planning)
	?f <- (stampa ?id)
	?s <- (solution_steps ?sol-steps)
    (kagent_node (ident ?id) (direction ?d-nuova) (father ?anc&~NA))  
    (kagent_exec ?anc ?id ?oper ?r ?c ?d-prec ?d-nuova)
 => 
	(printout t " Eseguo azione " ?oper " da stato (" ?r "," ?c ") con direzione " ?d-prec crlf)
	(assert (move ?sol-steps ?oper ?r ?c ?d-prec))
	(assert (solution_steps (+ ?sol-steps 1)))
	(assert (stampa ?anc))
	(retract ?s)
    (retract ?f)
)

(defrule stampa-fine
	(declare (salience 102))
	(planning)
    (stampa ?id)
    (kagent_node (ident ?id) (father ?anc&NA))
    (open-worse ?worse)
    (open-better ?better)
    (alreadyclosed ?closed)
    (numberofnodes ?n) 
    ?s <- (solution_steps ?sol-steps)
    (current_goal ?gid)
    ?gl <- (goal (goal-id ?gid))
 =>
 	(printout t " La soluzione e' costituita da " ?sol-steps " azioni" crlf)
 	(assert	(way_point_step 0))
 	(assert (solution_steps (- ?sol-steps 1)))
	(retract ?s)
	(printout t " stati espansi " ?n crlf)
	(printout t " stati generati gia' in closed " ?closed crlf)
	(printout t " stati generati gia' in open (open-worse) " ?worse crlf)
	(printout t " stati generati gia' in open (open-better) " ?better crlf)
	(modify ?gl (goal-steps ?sol-steps))
;//~ 	(halt)
)

;//~ NOTA BENE way_point commentati per evitare di asserirli ogni volta
;//~  e doverli gestire/cancellare ogni volta.
;//~ Li asserisco solo in caso di getaway
(defrule reverse-solution-first-step
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step 0)
	(move ?sol-steps ?oper ?r ?c ?d)
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step 0) (plan-time 0)
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step 1))
	(retract ?s ?w)
)

(defrule reverse-solution-go-forward
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step ?wp-step)
	(move ?sol-steps ?oper ?r ?c ?d)
	(way_point (plan-step =(- ?wp-step 1)) (plan-time ?t) (plan-action go-forward))
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step ?wp-step) (plan-time (+ ?t 10))
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step (+ ?wp-step 1)))
	(retract ?s ?w)
)

(defrule reverse-solution-go-left
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step ?wp-step)
	(move ?sol-steps ?oper ?r ?c ?d)
	(way_point (plan-step =(- ?wp-step 1)) (plan-time ?t) (plan-action go-left))
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step ?wp-step) (plan-time (+ ?t 15))
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step (+ ?wp-step 1)))
	(retract ?s ?w)
)

(defrule reverse-solution-go-right
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step ?wp-step)
	(move ?sol-steps ?oper ?r ?c ?d)
	(way_point (plan-step =(- ?wp-step 1)) (plan-time ?t) (plan-action go-right))
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step ?wp-step) (plan-time (+ ?t 15))
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step (+ ?wp-step 1)))
	(retract ?s ?w)
)

(defrule stop-planning
	(declare (salience 103))
	(solution_steps -1)
	?p <- (planning)
 =>
	(retract ?p)
)

;//~ pulizia in tutti i casi
(defrule clean-planner-module0
	(declare (salience -1))
	(not (planning))
	?ln <- (lastnode $?)
	?ac <- (alreadyclosed $?)
	?nn <- (numberofnodes $?)
	?ow <- (open-worse $?)
	?ob <- (open-better $?)
 =>
	(retract ?ln ?ac ?nn ?ow ?ob)
)

;//~ pulizia in caso piano riuscito
(defrule clean-planner-module1
	(declare (salience -1))
	(not (planning))
	?st <- (stampa $?)
	?wps <- (way_point_step $?)
	?sols <- (solution_steps $?)
	?c <- (current_node $?)
 =>
	(retract ?st ?wps ?sols ?c)
)

;//~ pulizia in caso piano fallito
(defrule clean-planner-module2
	(declare (salience -1))
	(not (planning))
	?plp <- (plan_local_pos (p ?))
 =>
	(retract ?plp)
)

;//~ pulizia fatti move
(defrule clean-planner-module3
	(declare (salience -1))
	(not (planning))
	?mv <- (move $?)
 =>
	(retract ?mv)
)

;//~ pulizia fatti kagent_node
(defrule clean-planner-module4
	(declare (salience -1))
	(not (planning))
	?kn <- (kagent_node (ident ?))
 =>
	(retract ?kn)
)

;//~ pulizia fatti kagent_exec
(defrule clean-planner-module5
	(declare (salience -1))
	(not (planning))
	?ke <- (kagent_exec $?)
 =>
	(retract ?ke)
)

(defrule pause-after-planning
	(declare (salience -2))
	(not (planning))
 =>
	(halt)
)

;//~ ;;;;;;; Utilizziamo un fatto di comodo plan_local_pos 	   ;;;;;;;;;;;;
;//~ ;;;;;;; per mantenere il riferimento alle celle adiacenti ;;;;;;;;;;;;

(defrule update-plan-local-pos-north
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction north)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r =(+ ?r 1)) (c ?c))
		(plan_local_pos (p 4) (r ?r) (c =(- ?c 1)))
		(plan_local_pos (p 6) (r ?r) (c =(+ ?c 1)))
	)
)

(defrule update-plan-local-pos-south
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction south)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r =(- ?r 1)) (c ?c))
		(plan_local_pos (p 4) (r ?r) (c =(+ ?c 1)))
		(plan_local_pos (p 6) (r ?r) (c =(- ?c 1)))
	)
)

(defrule update-plan-local-pos-east
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction east)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r ?r) (c =(+ ?c 1)))
		(plan_local_pos (p 4) (r =(+ ?r 1)) (c ?c))
		(plan_local_pos (p 6) (r =(- ?r 1)) (c ?c))
	)
)

(defrule update-plan-local-pos-west
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction west)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r ?r) (c =(- ?c 1)))
		(plan_local_pos (p 4) (r =(- ?r 1)) (c ?c))
		(plan_local_pos (p 6) (r =(+ ?r 1)) (c ?c))
	)
)

;//~ ;;;;;;; ATTENZIONE: calcolo g(n) = +10 per op. forward, +15 per op. left e right.
;//~ ;;;;;;;				calcolo f(n) = prima dist. Manhattan, ora moltiplicato * 10.


;//~ Aggiunta salience per preferire forward a right, e a sua volta right a left
(defrule forward-apply
	(declare (salience 52))
	(planning)
	(current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction ?d-prec) (open yes))
	(plan_local_pos (p 2) (r ?r) (c ?c))
	(kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 => 
	(assert (apply ?curr go-forward ?r-prec ?c-prec ?d-prec))
)

(defrule forward-exec
	(declare (salience 52))
	(planning)
    (current_node ?curr)
    (lastnode ?n)
	?f1<- (apply ?curr go-forward ?r-prec ?c-prec ?d-nuova)
	(plan_local_pos (p 2) (r ?r) (c ?c))
	(kagent_node (ident ?curr) (direction ?d-prec) (gcost ?g))
    (current_goal ?gid)
    (goal (goal-id ?gid) (goal-r ?y) (goal-c ?x) (goal-direction ?dir))
 =>
	(assert 
		(kagent_exec ?curr (+ ?n 1) go-forward ?r-prec ?c-prec ?d-prec ?d-nuova)
		(kagent_newnode 
			(ident (+ ?n 1)) 
			(pos-r ?r) (pos-c ?c) 
			(direction ?d-nuova)
			(gcost (+ ?g 10)) (fcost (+ (* (+ (abs (- ?x ?r)) (abs (- ?y ?c))) 10) ?g 10))
			(father ?curr)
		)
	)
	(retract ?f1)
	(focus NEW)
)

;//~ Aggiunta salience per preferire forward a right, e a sua volta right a left
(defrule right-apply-north
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction north) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec east))
)

(defrule right-apply-south
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction south) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec west))
)

(defrule right-apply-east
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction east) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec south))
)

(defrule right-apply-west
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction west) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec north))
)

(defrule right-exec
	(declare (salience 51))
	(planning)
	(current_node ?curr)
	(lastnode ?n)
	?f1 <- (apply ?curr go-right ?r-prec ?c-prec ?d-nuova)
	(plan_local_pos (p 6) (r ?r) (c ?c))
	(kagent_node (ident ?curr) (direction ?d-prec) (gcost ?g))
    (current_goal ?gid)
    (goal (goal-id ?gid) (goal-r ?y) (goal-c ?x) (goal-direction ?dir))
 =>
	(assert 
		(kagent_exec ?curr (+ ?n 3) go-right ?r-prec ?c-prec ?d-prec ?d-nuova)
		(kagent_newnode
			(ident (+ ?n 3))
			(pos-r ?r) (pos-c ?c)
			(direction ?d-nuova)
			(gcost (+ ?g 15)) (fcost (+ (* (+ (abs (- ?y ?c)) (abs (- ?x ?r))) 10) ?g 15))
			(father ?curr)
		)
	)
	(retract ?f1)
	(focus NEW)
)

;//~ Aggiunta salience per preferire forward a right, e a sua volta right a left
(defrule left-apply-north
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction north) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec west))
)

(defrule left-apply-south
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction south) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec east))
)

(defrule left-apply-east
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction east) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec north))
)

(defrule left-apply-west
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction west) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec south))
)

(defrule left-exec
	(declare (salience 50))
	(planning)
    (current_node ?curr)
    (lastnode ?n)
	?f1<- (apply ?curr go-left ?r-prec ?c-prec ?d-nuova)
	(plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_node (ident ?curr) (direction ?d-prec) (gcost ?g))
	(current_goal ?gid)
    (goal (goal-id ?gid) (goal-r ?y) (goal-c ?x) (goal-direction ?dir))
 =>
	(assert
		(kagent_exec ?curr (+ ?n 4) go-left ?r-prec ?c-prec ?d-prec ?d-nuova)
		(kagent_newnode
			(ident (+ ?n 4))
			(pos-r ?r) (pos-c ?c)
			(direction ?d-nuova)
			(gcost (+ ?g 15)) (fcost (+ (* (+ (abs (- ?y ?c)) (abs (- ?x ?r))) 10) ?g 15))
			(father ?curr)
		)
	)
	(retract ?f1)
    (focus NEW)
)

(defrule change-current_node
	(declare (salience 49))
	(planning)
	?f1 <- (current_node ?curr)
	?f2 <- (kagent_node (ident ?curr))
    (kagent_node (ident ?best&:(neq ?best ?curr)) (fcost ?bestcost) (open yes))
    (not (kagent_node (ident ?id&:(neq ?id ?curr)) (fcost ?gg&:(< ?gg ?bestcost)) (open yes)))
	?f3 <- (lastnode ?last)
	?p2 <- (plan_local_pos (p 2))
	?p4 <- (plan_local_pos (p 4))
	?p6 <- (plan_local_pos (p 6))
 =>
	(assert (current_node ?best) (lastnode (+ ?last 5)))
    (retract ?f1 ?f3 ?p2 ?p4 ?p6)
    (modify ?f2 (open no))
) 

(defrule close-empty
	(declare (salience 49))
	?p <- (planning)
	?f1 <- (current_node ?curr)
	?f2 <- (kagent_node (ident ?curr))
    (not (kagent_node (ident ?id&:(neq ?id ?curr)) (open yes)))
    (current_goal ?gid)
    ?gl <- (goal (goal-id ?gid) (goal-r ?r) (goal-c ?c) (goal-direction ?d))
    (numberofnodes ?non)
 => 
    (retract ?f1)
    (modify ?f2 (open no))
    (printout t " fail (last  kagent_node expanded " ?curr "): (" ?r ", " ?c", " ?d ") dopo " ?non " nodi" crlf)
	(modify ?gl (goal-status failed))
	(retract ?p)
;//~     (halt)
)    
                     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule NEW (import PLANNER ?ALL) (export ?ALL))

(defrule check-closed
	(declare (salience 50))
	(planning) 
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d))
	(kagent_node (ident ?old) (pos-r ?r) (pos-c ?c) (open no) (direction ?d))
	?f2 <- (alreadyclosed ?a)
 =>
	(assert (alreadyclosed (+ ?a 1)))
    (retract ?f1)
    (retract ?f2)
    (pop-focus)
)

(defrule check-open-worse
	(declare (salience 50))
	(planning)
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (father ?anc))
    (kagent_node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes))
    (test (or (> ?g ?g-old) (= ?g-old ?g)))
	?f2 <- (open-worse ?a)
 =>
    (assert (open-worse (+ ?a 1)))
    (retract ?f1)
    (retract ?f2)
    (pop-focus)
)

(defrule check-open-better
	(declare (salience 50))
	(planning) 
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc))
	?f2 <- (kagent_node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes))
    (test (<  ?g ?g-old))
	?f3 <- (open-better ?a)
 => 
	(assert
		(kagent_node
			(ident ?id)
			(pos-r ?r) (pos-c ?c)
			(direction ?d)
			(gcost ?g) (fcost ?f)
			(father ?anc) (open yes)
		)
	)
    (assert (open-better (+ ?a 1)))
    (retract ?f1 ?f2 ?f3)
    (pop-focus)
)

(defrule add-open
	(declare (salience 49))
	(planning)
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc))
	?f2 <- (numberofnodes ?a)
 => 
	(assert 
		(kagent_node 
			(ident ?id)
			(pos-r ?r) (pos-c ?c)
			(direction ?d)
			(gcost ?g) (fcost ?f)
			(father ?anc) (open yes)
		)
	)
    (assert (numberofnodes (+ ?a 1)))
    (retract ?f1 ?f2)
    (pop-focus)
)


;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;; TURNI ;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~         
;//~ (defrule turno1
;//~  ?f <-   (status (step 1))
;//~     =>  (printout t crlf crlf)
;//~         (printout t "aziono 1")
;//~         (printout t crlf)
;//~         (assert (exec (action loiter-monitoring) (step 1)))
;//~ )
;//~         
;//~ (defrule turno2
;//~  ?f <-   (status (step 2))
;//~     =>  (printout t crlf crlf)
;//~         (printout t "aziono 2")
;//~         (printout t crlf)
;//~         (assert (exec (action loiter) (step 2)))
;//~ )
;//~         
;//~ (defrule turno3
;//~  ?f <-   (status (step 3))
;//~     =>  (printout t crlf crlf)
;//~         (printout t "aziono 3")
;//~         (printout t crlf)
;//~         (assert (exec (action go-forward) (step 3)))
;//~ )
;//~ 
;//~ (defrule turno4
;//~  ?f <-   (status (step 4))
;//~      => (printout t crlf crlf)
;//~         (printout t "aziono 4")
;//~         (printout t crlf)
;//~ 		(assert (exec (action inform) (param1 6) (param2 6) (param3 flood) (step 4)))
;//~ )
;//~ 
;//~ (defrule turno5
;//~  ?f <-   (status (step 5))
;//~     =>  (printout t crlf crlf)
;//~         (printout t "aziono 5")
;//~         (printout t crlf)
;//~         (assert (exec (action go-left) (step 5))))
;//~ 
;//~ 
;//~ (defrule turno6
;//~  ?f <-   (status (step 6))
;//~     =>  (printout t crlf crlf)
;//~         (printout t "aziono 6")
;//~         (printout t crlf crlf)
;//~         (assert (exec (action inform) (param1 4) (param2 3) (param3 flood) (step 6))))
;//~ 
;//~ (defrule turno7
;//~  ?f <-   (status (step 7))
;//~     =>  (printout t crlf crlf)
;//~         (printout t "aziono 7")
;//~         (printout t crlf crlf)
;//~         (assert (exec (action inform) (param1 5) (param2 4) (param3 flood) (step 7))))
;//~ 
;//~ (defrule turno8
;//~  ?f <-   (status (step 8))
;//~     =>  (printout t crlf crlf)
;//~         (printout t "aziono 8")
;//~         (printout t crlf crlf)
;//~         (assert (exec (action inform) (param1 4) (param2 4) (param3 flood) (step 8))))
