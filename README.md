# Progetto Reti Logiche 2023/2024

## Descrizione
Progetto accademico sviluppato in **VHDL** per il corso *Progetto di Reti Logiche* (A.A. 2023/2024), volto alla realizzazione di un componente hardware capace di:
- Analizzare e validare dati provenienti da un sensore;
- Sostituire valori non validi con l’ultimo dato valido;
- Aggiornare dinamicamente la **credibilità** associata a ciascun dato.

Il progetto è stato valutato **30 e lode**.

## Struttura della Repository
```

Progetto-Reti-Logiche-2023-2024/
├── project_reti_logiche.vhd        # Codice sorgente VHDL del componente principale
├── test_benches/                   # Directory contenente i test bench utilizzati
├── documentazione.pdf              # Relazione tecnica completa del progetto
└── specifa.pdf                     # Specifica ufficiale della consegna

```

## Sintesi del Lavoro
- **Tecnologia target:** FPGA Artix-7 (xc7a200tfbg484-1)  
- **Linguaggio:** VHDL  
- **Architettura:** modulare con FSM di controllo  
- **Test:** numerosi test bench sviluppati per casi limite e sequenze lunghe  
- **Risultati:** corretta sintesi e superamento di tutti i test funzionali e temporali  

## Autore
**Luigi Inguaggiato**  
Corso: *Progetto di Reti Logiche*  
Docente: Prof. Fabio Salice  
Anno Accademico: 2023/2024