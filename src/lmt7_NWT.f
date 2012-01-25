C
C ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C LINK-MT3DMS (LMT) PACKAGE V7 FOR MODFLOW-2005
C Modified from LMT V6 for MODFLOW-2000 as documented in:
C     Zheng, C., M.C. Hill, and P.A. Hsieh, 2001,
C         MODFLOW-2000, the U.S. Geological Survey modular ground-water
C         model--User guide to the LMT6 Package, the linkage with
C         MT3DMS for multispecies mass transport modeling:
C         U.S. Geological Survey Open-File Report 01-82
C
C Revision History: 
C     Version 7.0: 08-08-2008 cz
C ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
C
C
      SUBROUTINE LMT7BAS7(INUNIT,CUNIT,ISSMT3D,IUMT3D,ILMTFMT,IGRID)
C **********************************************************************
C OPEN AND READ THE INPUT FILE FOR THE LINK-MT3DMS PACKAGE VERSION 7.
C CHECK KEY FLOW MODEL INFORMATION AND SAVE IT IN THE HEADER OF
C THE MODFLOW-MT3DMS LINK FILE FOR USE IN MT3DMS TRANSPORT SIMULATION.
C NOTE THE 'STANDARD' HEADER OPTION IS NO LONGER SUPPORTED. INSTEAD,
C THE 'EXTENDED' HEADER OPTION IS THE DEFAULT. THE RESULTING LINK FILE 
C IS ONLY COMPATIBLE WITH MT3DMS VERSION [4.00] OR LATER.
!rgn------REVISION NUMBER CHANGED TO INDICATE MODIFICATIONS FOR NWT 
!rgn------RELEASE. NEW VERSION NUMBER 1.0.4:  JANUARY 25, 2012
C **********************************************************************
C last modified: 08-08-2008
C      
      USE GLOBAL,   ONLY:NCOL,NROW,NLAY,NPER,NODES,NIUNIT,IUNIT,
     &                   ISSFLG,IBOUND,IOUT
      LOGICAL       LOP
      CHARACTER*4   CUNIT(NIUNIT)
      CHARACTER*200 LINE,FNAME,NME
      CHARACTER*8   OUTPUT_FILE_HEADER
      CHARACTER*11  OUTPUT_FILE_FORMAT      
      DATA          INLMT,MTBCF,MTLPF,MTHUF,MTWEL,MTDRN,MTRCH,MTEVT,
     &              MTRIV,MTSTR,MTGHB,MTRES,MTFHB,MTDRT,MTETS,MTSUB,
     &              MTIBS,MTLAK,MTMNW,MTSWT,MTSFR,MTUZF
     &             /22*0/
C     -----------------------------------------------------------------    
C
C--USE FILE SPECIFICATION of MODFLOW-2005
      INCLUDE 'openspec.inc'
C
C--SET POINTERS FOR THE CURRENT GRID 
      CALL SGWF2BAS7PNT(IGRID)     
C
C--CHECK for OPTIONS/PACKAGES USED IN CURRENT SIMULATION
      IUMT3D=0
      DO IU=1,NIUNIT
        IF(CUNIT(IU).EQ.'LMT6') THEN
          INLMT=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'BCF6') THEN
          MTBCF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'LPF ') THEN
          MTLPF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'HUF2') THEN
          MTHUF=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'WEL ') THEN
          MTWEL=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'DRN ') THEN
          MTDRN=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RCH ') THEN
          MTRCH=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'EVT ') THEN
          MTEVT=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RIV ') THEN
          MTRIV=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'STR ') THEN
          MTSTR=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'GHB ') THEN
          MTGHB=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'RES ') THEN
          MTRES=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'FHB ') THEN
          MTFHB=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'DRT ') THEN
          MTDRT=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'ETS ') THEN
          MTETS=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'SUB ') THEN
          MTSUB=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'IBS ') THEN
          MTIBS=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'LAK ') THEN
          MTLAK=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'MNW1'.OR.CUNIT(IU).EQ.'MNW2') THEN
          MTMNW=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'SWT ') THEN
          MTSWT=IUNIT(IU)        
        ELSEIF(CUNIT(IU).EQ.'SFR ') THEN
          MTSFR=IUNIT(IU)
        ELSEIF(CUNIT(IU).EQ.'UZF ') THEN
          MTUZF=IUNIT(IU)
        ENDIF
      ENDDO            
C
C--IF LMT7 PACKAGE IS NOT ACTIVATED, SKIP TO END AND RETURN
      IF(INLMT.EQ.0) GOTO 9999
C
C--ASSIGN DEFAULTS TO LMT INPUT VARIABLES AND OUTPUT FILE NAME
      IUMT3D=333
      OUTPUT_FILE_HEADER='EXTENDED'
      ILMTHEAD=1
      OUTPUT_FILE_FORMAT='UNFORMATTED'
      ILMTFMT=0     
      INQUIRE(UNIT=INLMT,NAME=NME,OPENED=LOP)
      IFLEN=INDEX(NME,' ')-1
      DO NC=IFLEN,2,-1
        IF(NME(NC:NC).EQ.'.') THEN      
          FNAME=NME(1:NC-1)//'.FTL'
          GO TO 10
        ENDIF
      ENDDO    
      FNAME=NME(1:IFLEN)//'.FTL'     
C
C--READ ONE LINE OF LMT PACKAGE INPUT FILE
   10 READ(INLMT,'(A)',END=1000) LINE
      IF(LINE.EQ.' ') GOTO 10
      IF(LINE(1:1).EQ.'#') GOTO 10
C
C--DECODE THE INPUT RECORD
      LLOC=1
      CALL URWORD(LINE,LLOC,ITYP1,ITYP2,1,N,R,IOUT,INLMT)
C
C--CHECK FOR "OUTPUT_FILE_NAME" KEYWORD AND GET FILE NAME
      IF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_NAME') THEN
        CALL URWORD(LINE,LLOC,INAM1,INAM2,0,N,R,IOUT,INLMT)
        IFLEN=INAM2-INAM1+1
        IF(LINE(INAM1:INAM2).EQ.' ') THEN
        ELSE
          FNAME=LINE(INAM1:INAM2)
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_UNIT" KEYWORD AND GET UNIT NUMBER
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_UNIT') THEN
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,2,IU,R,IOUT,INLMT)
        IF(IU.GT.0) THEN
          IUMT3D=IU
        ELSEIF(IU.LT.0) THEN
          WRITE(IOUT,11) IU
          WRITE(*,11) IU
          CALL USTOP(' ')
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_HEADER" KEYWORD AND GET INPUT VALUE
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_HEADER') THEN
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INLMT)
        IF(LINE(ISTART:ISTOP).EQ.' '.OR.
     &     LINE(ISTART:ISTOP).EQ.'EXTENDED') THEN
          OUTPUT_FILE_HEADER='EXTENDED'
          ILMTHEAD=1
        ELSEIF(LINE(ISTART:ISTOP).EQ.'STANDARD') THEN
          WRITE(IOUT,120)
          WRITE(*,120)                   
        ELSE
          WRITE(IOUT,12) LINE(ISTART:ISTOP)
          WRITE(*,12) LINE(ISTART:ISTOP)
          CALL USTOP(' ')
        ENDIF
C
C--CHECK FOR "OUTPUT_FILE_FORMAT" KEYWORD AND GET INPUT VALUE
      ELSEIF(LINE(ITYP1:ITYP2).EQ.'OUTPUT_FILE_FORMAT') THEN
        CALL URWORD(LINE,LLOC,ISTART,ISTOP,1,N,R,IOUT,INLMT)
        IF(LINE(ISTART:ISTOP).EQ.' '.OR.
     &     LINE(ISTART:ISTOP).EQ.'UNFORMATTED') THEN
          OUTPUT_FILE_FORMAT='UNFORMATTED'
          ILMTFMT=0
        ELSEIF(LINE(ISTART:ISTOP).EQ.'FORMATTED') THEN
          OUTPUT_FILE_FORMAT='FORMATTED'
          ILMTFMT=1
        ELSE
          WRITE(IOUT,14) LINE(ISTART:ISTOP)
          WRITE(*,14) LINE(ISTART:ISTOP)
          CALL USTOP(' ')
        ENDIF
C
C--ERROR DECODING LMT INPUT KEYWORDS
      ELSE
        WRITE(IOUT,28) LINE
        WRITE(*,28) LINE
        CALL USTOP(' ')
      ENDIF
C
C--CONTINUE TO THE NEXT INPUT RECORD IN LMT FILE
      GOTO 10
C
   11 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT FILE UNIT: ',I5)
   12 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT_FILE_HEADER CODE: ',A)
   14 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'INVALID OUTPUT_FILE_FORMAT SPECIFIER: ',A)
   28 FORMAT(/1X,'ERROR READING LMT PACKAGE INPUT DATA:',
     & /1X,'UNRECOGNIZED KEYWORD: ',A)
  120 FORMAT(/1X,'WARNING READING LMT PACKAGE INPUT DATA:',
     &       /1X,'[STANDARD] HEADER NO LONGER SUPPORTED; ',
     &           '[EXTENDED] HEADER USED INSTEAD.')     
C     
 1000 CONTINUE     
C
C--ENSURE A UNIQUE UNIT NUMBER FOR LINK-MT3DMS OUTPUT FILE
      IF(IUMT3D.EQ.IOUT .OR. IUMT3D.EQ.INUNIT) THEN
        WRITE(IOUT,1010) IUMT3D
        WRITE(*,1010) IUMT3D
        CALL USTOP(' ')
      ELSE
        DO IU=1,NIUNIT       
          IF(IUMT3D.EQ.IUNIT(IU)) THEN
            WRITE(IOUT,1010) IUMT3D
            WRITE(*,1010) IUMT3D
            CALL USTOP(' ')
          ENDIF
        ENDDO
      ENDIF  
 1010 FORMAT(/1X,'ERROR IN LMT PACKAGE INPT DATA:'
     &       /1X,'UNIT NUMBER GIVEN FOR FLOW-TRANSPORT LINK FILE:', 
     &        I4,' ALREADY IN USE;' 
     &       /1X,'SPECIFY A UNIQUE UNIT NUMBER.')   
C
C--OPEN THE LINK-MT3DMS OUTPUT FILE NEEDED BY MT3DMS
C--AND PRINT AN IDENTIFYING MESSAGE IN MODFLOW OUTPUT FILE  
      INQUIRE(UNIT=IUMT3D,OPENED=LOP)
      IF(LOP) THEN
        REWIND (IUMT3D)
      ELSE
        IF(ILMTFMT.EQ.0) THEN
          OPEN(IUMT3D,FILE=FNAME,FORM=FORM,ACCESS=ACCESS,
     &      ACTION=ACTION(2),STATUS='REPLACE')
        ELSEIF(ILMTFMT.EQ.1) THEN
          OPEN(IUMT3D,FILE=FNAME,FORM='FORMATTED',ACTION=ACTION(2),
     &      STATUS='REPLACE',DELIM='APOSTROPHE')
        ENDIF
      ENDIF
C
      WRITE(IOUT,30) FNAME,IUMT3D,
     &               OUTPUT_FILE_FORMAT,OUTPUT_FILE_HEADER
   30 FORMAT(//1X,'***Link-MT3DMS Package v7***',
     &        /1x,'OPENING LINK-MT3DMS OUTPUT FILE: ',A,
     &        /1X,'ON UNIT NUMBER: ',I5,
     &        /1X,'FILE TYPE: ',A,
     &        /1X,'HEADER OPTION: ',A,
     &        /1X,'***Link-MT3DMS Package v7***',/1X)
C
C--GATHER AND CHECK KEY FLOW MODEL INFORMATION
      ISSMT3D=1    !loop through all stress periods        
      DO N=1,NPER    !to check if any transient sp is used
        IF(ISSFLG(N).EQ.0) THEN
          ISSMT3D=0
          EXIT
        ENDIF
      ENDDO                  
      MTISS=ISSMT3D
      MTNPER=NPER 
C
      MTCHD=0    !loop through the entire grid to get
      DO K=1,NLAY    !total number of constant-head cells
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).LT.0) MTCHD=MTCHD+1
          ENDDO
        ENDDO
      ENDDO
C
C--ERROR CHECKING BEFORT OUTPUT
      IF(MTEVT.GT.0.AND.MTETS.GT.0) THEN
        WRITE(IOUT,1300)
        WRITE(*,1300)
        CALL USTOP(' ')
      ENDIF    
 1300 FORMAT(/1X,'ERROR IN LMT PACKAGE INPT DATA:'
     &  /1X,'Both EVT and ETS Packages are used in flow simulation;'
     &  /1X,'Only one is allowed in the same transport simulation.')
C
C--WRITE A HEADER TO MODFLOW-MT3DMS LINK FILE
      IF(OUTPUT_FILE_HEADER.EQ.'EXTENDED') THEN        
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) 'MT3D4.00.00',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER,
     &     MTSTR,MTRES,MTFHB,MTDRT,MTETS,MTSUB,MTIBS,MTLAK,MTMNW,
     &     MTSWT,MTSFR,MTUZF
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) 'MT3D4.00.00',
     &     MTWEL,MTDRN,MTRCH,MTEVT,MTRIV,MTGHB,MTCHD,MTISS,MTNPER,
     &     MTSTR,MTRES,MTFHB,MTDRT,MTETS,MTSUB,MTIBS,MTLAK,MTMNW,
     &     MTSWT,MTSFR,MTUZF
        ENDIF
      ENDIF
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7BCF7(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE SATURATED CELL THICKNESS; FLOW ACROSS THREE CELL INTERFACES;
C TRANSIENT FLUID-STORAGE; AND LOCATIONS AND FLOW RATES OF
C CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'BCF' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,
     &                      BUFF,CR,CC,CV,BOTM,LBOTM
      USE GWFBASMODULE,ONLY:DELT
      USE GWFBCFMODULE,ONLY:LAYCON,SC1,SC2
      CHARACTER*16 TEXT     
      DOUBLE PRECISION HD
C
C--SET POINTERS FOR THE CURRENT GRID     
      CALL SGWF2BCF7PNT(IGRID)      
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD               
      ISSCURRENT=ISSFLG(KPER)
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS   
      FlagInactive=1.E30
      FlagActive=-111.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYCON(K).EQ.0 .OR. LAYCON(K).EQ.2) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              IF(LAYCON(K).EQ.3) THEN
                THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
                IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER     
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              BUFF(J,I,K)=HDIFF*CR(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              BUFF(J,I,K)=HDIFF*CC(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LAYCON(K+1).EQ.3 .OR. LAYCON(K+1).EQ.2) THEN
                TMP=HD
                IF(TMP.LT.BOTM(J,I,LBOTM(K+1)-1))
     &           HD=BOTM(J,I,LBOTM(K+1)-1)
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER
      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      KT=0
      DO K=1,NLAY
        LC=LAYCON(K)
        IF(LC.EQ.3 .OR. LC.EQ.2) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
              IF(LC.NE.3 .AND. LC.NE.2) THEN
                RHO=SC1(J,I,K)*TLED
                STRG=RHO*HOLD(J,I,K) - RHO*HSING
              ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                RHO2=SC2(J,I,KT)*TLED
                RHO1=SC1(J,I,K)*TLED
                SOLD=RHO2
                IF(HOLD(J,I,K).GT.TP) SOLD=RHO1
                SNEW=RHO2
                IF(HSING.GT.TP) SNEW=RHO1
                STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
              ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            X1=HDIFF*CR(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            X2=HDIFF*CR(J,I,K)
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            X3=HDIFF*CC(J,I-1,K)
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            X4=HDIFF*CC(J,I,K)
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYCON(K).NE.3 .AND. LAYCON(K).NE.2) GO TO 122
            TMP=HD
            IF(TMP.LT.BOTM(J,I,LBOTM(K)-1))
     &       HD=BOTM(J,I,LBOTM(K)-1)
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYCON(K+1).NE.3 .AND. LAYCON(K+1).NE.2) GO TO 152
            TMP=HD
            IF(TMP.LT.BOTM(J,I,LBOTM(K+1)-1))
     &       HD=BOTM(J,I,LBOTM(K+1)-1)
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)            
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)              
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT7LPF7(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'LPF' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh(2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,
     &                      BUFF,CR,CC,CV,BOTM,LBOTM
      USE GWFBASMODULE,ONLY:DELT
      USE GWFLPFMODULE,ONLY:LAYTYP,SC1,SC2
      CHARACTER*16 TEXT
      DOUBLE PRECISION HD
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2LPF7PNT(IGRID)
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD
      ISSCURRENT=ISSFLG(KPER)      
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      FlagInactive=1.E30
      FlagActive=-111.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYTYP(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              BUFF(J,I,K)=HDIFF*CR(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              BUFF(J,I,K)=HDIFF*CC(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LAYTYP(K+1).NE.0) THEN
                TMP=HD
                TOP=BOTM(J,I,LBOTM(K+1)-1)
                IF(TMP.LT.TOP) HD=TOP
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER           
      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      KT=0
      DO K=1,NLAY
        LC=LAYTYP(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
              IF(LC.EQ.0) THEN
                RHO=SC1(J,I,K)*TLED
                STRG=RHO*HOLD(J,I,K) - RHO*HSING
              ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                RHO2=SC2(J,I,KT)*TLED
                RHO1=SC1(J,I,K)*TLED
                SOLD=RHO2
                IF(HOLD(J,I,K).GT.TP) SOLD=RHO1
                SNEW=RHO2
                IF(HSING.GT.TP) SNEW=RHO1
                STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
              ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            X1=HDIFF*CR(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            X2=HDIFF*CR(J,I,K)
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            X3=HDIFF*CC(J,I-1,K)
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            X4=HDIFF*CC(J,I,K)
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYTYP(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
            IF(TMP.LT.TOP) HD=TOP
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYTYP(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
            IF(TMP.LT.TOP) HD=TOP
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
      SUBROUTINE LMT7UPW1(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'UPW' PACKAGE IS USED IN MODFLOW.
C *********************************************************************
C Modified from Harbaugh(2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,
     &                      BUFF,CR,CC,CV,BOTM,LBOTM
      USE GWFBASMODULE,ONLY:DELT
      USE GWFUPWMODULE,ONLY:LAYTYPUPW,SC1,SC2UPW,Sn,So
      USE GWFNWTMODULE,ONLY:Icell 
      CHARACTER*16 TEXT
      DOUBLE PRECISION HD, HH, CLOSEZERO
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2UPW1PNT(IGRID)
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD
      ISSCURRENT=ISSFLG(KPER)      
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.
      CLOSEZERO = 1.0e-7
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      FlagInactive=1.E30
      FlagActive=-111.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LAYTYPUPW(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
              IF(BUFF(J,I,K).LT.0.0) BUFF(J,I,K)=0.0
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL (have to check for upstream weighting.)
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              IF(LAYTYPUPW(K).NE.0) THEN
                IF ( HDIFF.GT.0.0 ) THEN
                  TTOP = BOTM(J,I,LBOTM(K)-1)
                  BBOT = BOTM(J,I,LBOTM(K))
                  HH = HNEW(J,I,K)
                  ij = Icell(J,I,K)
                ELSE
                  TTOP = BOTM(J+1,I,LBOTM(K)-1)
                  BBOT = BOTM(J+1,I,LBOTM(K))
                  HH = HNEW(J+1,I,K)
                  ij = Icell(J+1,I,K)
                END IF
                BUFF(J,I,K)=HDIFF*CR(J,I,K)*(TTOP-BBOT)*Sn(ij)
                IF ( HH-BBOT.LT.CLOSEZERO ) BUFF(J,I,K) = 0.0
              ELSE
                BUFF(J,I,K)=HDIFF*CR(J,I,K)
              END IF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              IF(LAYTYPUPW(K).NE.0) THEN
                IF ( HDIFF.GT.0.0 ) THEN
                  TTOP = BOTM(J,I,LBOTM(K)-1)
                  BBOT = BOTM(J,I,LBOTM(K))
                  HH = HNEW(J,I,K)
                  ij = Icell(J,I,K)
                ELSE
                  TTOP = BOTM(J,I+1,LBOTM(K)-1)
                  BBOT = BOTM(J,I+1,LBOTM(K))
                  HH = HNEW(J,I+1,K)
                  ij = Icell(J,I+1,K)
                END IF
                BUFF(J,I,K)=HDIFF*CC(J,I,K)*(TTOP-BBOT)*Sn(ij)
                IF ( HH-BBOT.LT.CLOSEZERO ) BUFF(J,I,K) = 0.0
              ELSE
                BUFF(J,I,K)=HDIFF*CC(J,I,K)
              END IF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL CALCULATE FLOW THRU LOWER FACE & STORE IN BUFFER
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
 !             IF(LAYTYPUPW(K+1).NE.0) THEN     ! No vertical correction for UPW.
 !               TMP=HD
 !               TOP=BOTM(J,I,LBOTM(K+1)-1)
 !               IF(TMP.LT.TOP) HD=TOP
 !             ENDIF
              IF ( HNEW(J,I,K).GT.BOTM(J,I,K) ) THEN
                HDIFF=HNEW(J,I,K)-HD
                BUFF(J,I,K)=HDIFF*CV(J,I,K)
              END IF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE AND CLEAR BUFFER           
      TLED=ONE/DELT
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C--RUN THROUGH EVERY CELL IN THE GRID
      KT=0
      DO K=1,NLAY
        LC=LAYTYPUPW(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C--CALCULATE FLOW FROM STORAGE (VARIABLE HEAD CELLS ONLY)
            IF(IBOUND(J,I,K).GT.0) THEN
              HSING=HNEW(J,I,K)
 !             IF(LC.EQ.0) THEN
 !               RHO=SC1(J,I,K)*TLED
 !               STRG=RHO*HOLD(J,I,K) - RHO*HSING
 !             ELSE
                TP=BOTM(J,I,LBOTM(K)-1)
                IF ( LC.GT.0 ) THEN
                  RHO2=SC2UPW(J,I,KT)*TLED
                ELSE
                  RHO2=0.0
                END IF
                RHO1=SC1(J,I,K)*TLED             
                TP=BOTM(J,I,LBOTM(K)-1)
                BT=BOTM(J,I,LBOTM(K))
                THICK = (TP-BT)
                RHO2 = SC2UPW(J,I,K)*TLED 
                ij = Icell(J,I,K)
                RHO1 = SC1(J,I,K)*TLED
                STRG= - THICK*RHO2*(Sn(ij)-So(ij)) - 
     +                  Sn(ij)*THICK*RHO1*(HSING-HOLD(J,I,K))
 !             ENDIF
              BUFF(J,I,K)=STRG
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF(IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
            HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I,K)
                X1=HDIFF*CR(J-1,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X1 = 0.0
              ELSE
                TTOP = BOTM(J-1,I,LBOTM(K)-1)
                BBOT = BOTM(J-1,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J-1,I,K)
                X1=HDIFF*CR(J-1,I,K)*THICK*Sn(ij)
                HH = HNEW(J-1,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X1 = 0.0
              END IF
            ELSE
              X1=HDIFF*CR(J-1,I,K)
            END IF
            
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I,K)
                X2=HDIFF*CR(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X2 = 0.0
              ELSE
                TTOP = BOTM(J+1,I,LBOTM(K)-1)
                BBOT = BOTM(J+1,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J+1,I,K)
                X2=HDIFF*CR(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J+1,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X2 = 0.0
              END IF
            ELSE
              X2=HDIFF*CR(J,I,K)
            END IF
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij =  Icell(J,I,K)
                X3=HDIFF*CC(J,I-1,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X3 = 0.0
              ELSE
                TTOP = BOTM(J,I-1,LBOTM(K)-1)
                BBOT = BOTM(J,I-1,LBOTM(K))
                THICK = TTOP - BBOT
                ij =  Icell(J,I-1,K)
                X3=HDIFF*CC(J,I-1,K)*THICK*Sn(ij)
                 HH = HNEW(J,I-1,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X3 = 0.0
              END IF
            ELSE
              X3=HDIFF*CC(J,I-1,K)
            END IF
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
            IF(LAYTYPUPW(K).NE.0) THEN
              IF ( HDIFF.GE.0.0 ) THEN
                TTOP = BOTM(J,I,LBOTM(K)-1)
                BBOT = BOTM(J,I,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I,K)
                X4=HDIFF*CC(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X4 = 0.0
              ELSE
                TTOP = BOTM(J,I+1,LBOTM(K)-1)
                BBOT = BOTM(J,I+1,LBOTM(K))
                THICK = TTOP - BBOT
                ij = Icell(J,I+1,K)
                X4=HDIFF*CC(J,I,K)*THICK*Sn(ij)
                HH = HNEW(J,I+1,K)
                IF ( HH-BBOT.LT.CLOSEZERO ) X4 = 0.0
              END IF
            ELSE
              X4=HDIFF*CC(J,I,K)
            END IF
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LAYTYPUPW(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
!            IF(TMP.LT.TOP) HD=TOP   ! No vertial correction for UPW.
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LAYTYPUPW(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
!            IF(TMP.LT.TOP) HD=TOP   ! No vertial correction for UPW.
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT7HUF7(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,ILVDA,IGRID)
C **********************************************************************
C SAVE FLOW ACROSS THREE CELL INTERFACES (QXX, QYY, QZZ), FLOW RATE TO
C OR FROM TRANSIENT FLUID-STORAGE (QSTO), AND LOCATIONS AND FLOW RATES
C OF CONSTANT-HEAD CELLS FOR USE BY MT3D.  THIS SUBROUTINE IS CALLED
C ONLY IF THE 'HUF' PACKAGE IS USED IN MODFLOW.
C **********************************************************************
C Modified from Anderman and Hill (2000), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,ISSFLG,IBOUND,HNEW,HOLD,BOTM,
     &                      LBOTM,DELR,DELC,BUFF,IOUT,CR,CC,CV
      USE GWFBASMODULE,ONLY:DELT
      USE GWFHUFMODULE,ONLY:LTHUF,SC1,HUFTHK,NHUF,VDHT      
      CHARACTER*16 TEXT
      DOUBLE PRECISION HD,DFL,DFR,DFT,DFB
C    
C--SET POINTERS FOR THE CURRENT GRID   
      CALL SGWF2HUF7PNT(IGRID) 
C      
C--GET STEADY-STATE FLAG FOR THE CURRENT STRESS PERIOD      
      ISSCURRENT=ISSFLG(KPER)
C
C--CALCULATE AND SAVE SATURATED THICKNESS
      TEXT='THKSAT'
      ZERO=0.
      ONE=1.   
C
C--INITIALIZE BUFF ARRAY WITH 1.E30 FOR INACTIVE CELLS
C--OR FLAG -111 FOR ACTIVE CELLS
      FlagInactive=1.E30
      FlagActive=-111.   
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).EQ.0) THEN
              BUFF(J,I,K)=FlagInactive
            ELSE
              BUFF(J,I,K)=FlagActive
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE SATURATED THICKNESS FOR UNCONFINED/CONVERTIBLE
C--LAYERS AND STORE IN ARRAY BUFF
      DO K=1,NLAY
        IF(LTHUF(K).EQ.0) CYCLE
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0) THEN
              TMP=HNEW(J,I,K)
              BUFF(J,I,K)=TMP-BOTM(J,I,LBOTM(K))
              THKLAY=BOTM(J,I,LBOTM(K)-1)-BOTM(J,I,LBOTM(K))
              IF(BUFF(J,I,K).GT.THKLAY) BUFF(J,I,K)=THKLAY
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--SAVE THE CONTENTS OF THE BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CALCULATE AND SAVE FLOW ACROSS RIGHT FACE
      NCM1=NCOL-1
      IF(NCM1.LT.1) GO TO 405
      TEXT='QXX'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCM1
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J+1,I,K).NE.0) THEN        
              if(ILVDA.gt.0) then
                CALL SGWF2HUF7VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &           NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)
                BUFF(J,I,K) = DFR
              else                       
                HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
                BUFF(J,I,K)=HDIFF*CR(J,I,K)
              endif  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  405 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS FRONT FACE
      NRM1=NROW-1
      IF(NRM1.LT.1) GO TO 505
      TEXT='QYY'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL
      DO K=1,NLAY
        DO I=1,NRM1
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I+1,K).NE.0) THEN
              if(ILVDA.gt.0) then
                CALL SGWF2HUF7VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &           NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)
                BUFF(J,I,K) = DFT
              else                        
                HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
                BUFF(J,I,K)=HDIFF*CC(J,I,K)
              endif  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  505 CONTINUE
C
C--CALCULATE AND SAVE FLOW ACROSS LOWER FACE
      NLM1=NLAY-1
      IF(NLM1.LT.1) GO TO 700
      TEXT='QZZ'
C
C--CLEAR THE BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL 
      DO K=1,NLM1
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).NE.0.AND.IBOUND(J,I,K+1).NE.0) THEN
              HD=HNEW(J,I,K+1)
              IF(LTHUF(K+1).NE.0) THEN
                TMP=HD
                TOP=BOTM(J,I,LBOTM(K+1)-1)
                IF(TMP.LT.TOP) HD=TOP
              ENDIF
              HDIFF=HNEW(J,I,K)-HD
              BUFF(J,I,K)=HDIFF*CV(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  700 CONTINUE
C
C--CALCULATE AND SAVE GROUNDWATER STORAGE IF TRANSIENT
      IF(ISSMT3D.NE.0) GO TO 705
      TEXT='STO'
C
C--INITIALIZE and CLEAR BUFFER
      TLED=ONE/DELT
      DO K=1,NLAY 
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
      IF(ISSCURRENT.NE.0) GOTO 704
C
C5------LOOP THROUGH EVERY CELL IN THE GRID.
      KT=0
      DO K=1,NLAY
        LC=LTHUF(K)
        IF(LC.NE.0) KT=KT+1
        DO I=1,NROW
          DO J=1,NCOL
C
C6------SKIP NO-FLOW AND CONSTANT-HEAD CELLS.
            IF(IBOUND(J,I,K).LE.0) CYCLE
            HN=HNEW(J,I,K)
            HO=HOLD(J,I,K)
            STRG=ZERO
C
C7-----CHECK LAYER TYPE TO SEE IF ONE STORAGE CAPACITY OR TWO.
            IF(LC.EQ.0) GO TO 285
            TOP=BOTM(J,I,LBOTM(K)-1)
            BOT=BOTM(J,I,LBOTM(K))
            IF(HO.GT.TOP.AND.HN.GT.TOP) GOTO 285
C
C7A----TWO STORAGE CAPACITIES.
C---------------Compute SC1 Component
            IF(HO.GT.TOP) THEN
              STRG=SC1(J,I,K)*(HO-TOP)*TLED
            ELSEIF(HN.GT.TOP) THEN
              STRG=SC1(J,I,K)*TLED*(TOP-HN)
            ENDIF
C---------------Compute SC2 Component
            CALL SGWF2HUF7SC2(1,J,I,K,TOP,BOT,HN,HO,TLED,CHCOF,STRG,
     &       HUFTHK,NCOL,NROW,NHUF,DELR(J)*DELC(I),IOUT)          
C------STRG=SOLD*(HOLD(J,I,K)-TP) + SNEW*TP - SNEW*HSING
            GOTO 288
C
C7B----ONE STORAGE CAPACITY.
  285       RHO=SC1(J,I,K)*TLED
            STRG=RHO*(HO-HN)
C
C8-----STORE CELL-BY-CELL FLOW IN BUFFER
  288       BUFF(J,I,K)=STRG
C
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
  704 IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
  705 CONTINUE
C
C--CALCULATE FLOW INTO OR OUT OF CONSTANT-HEAD CELLS
      TEXT='CNH'
      NCNH=0
C
C--CLEAR BUFFER
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            BUFF(J,I,K)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH CELL IF IT IS CONSTANT HEAD COMPUTE FLOW ACROSS 6
C--FACES.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--IF CELL IS NOT CONSTANT HEAD SKIP IT & GO ON TO NEXT CELL.
            IF (IBOUND(J,I,K).GE.0) CYCLE
            NCNH=NCNH+1
C
C--CLEAR FIELDS FOR SIX FLOW RATES.
            X1=ZERO
            X2=ZERO
            X3=ZERO
            X4=ZERO
            X5=ZERO
            X6=ZERO
C            
C--COMPUTE HORIZONTAL FLUXES IF THE LVDA CAPABILITY IS USED            
            if(ILVDA.gt.0)
     &       CALL SGWF2HUF7VDF9(I,J,K,VDHT,HNEW,IBOUND,
     &       NLAY,NROW,NCOL,DFL,DFR,DFT,DFB)                        
C
C--CALCULATE FLOW THROUGH THE LEFT FACE
C
C--IF THERE IS AN INACTIVE CELL ON THE OTHER SIDE OF THIS
C--FACE THEN GO ON TO THE NEXT FACE.
            IF(J.EQ.1) GO TO 30
            IF(IBOUND(J-1,I,K).EQ.0) GO TO 30
C
C--CALCULATE FLOW THROUGH THIS FACE INTO THE ADJACENT CELL.
            if(ILVDA.gt.0) then
              X1 = -DFL
            else
              HDIFF=HNEW(J,I,K)-HNEW(J-1,I,K)            
              X1=HDIFF*CR(J-1,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE RIGHT FACE
   30       IF(J.EQ.NCOL) GO TO 60
            IF(IBOUND(J+1,I,K).EQ.0) GO TO 60
            if(ILVDA.gt.0) then
              X2 = DFR
            else                       
              HDIFF=HNEW(J,I,K)-HNEW(J+1,I,K)
              X2=HDIFF*CR(J,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE BACK FACE.
   60       IF(I.EQ.1) GO TO 90
            IF (IBOUND(J,I-1,K).EQ.0) GO TO 90
            if(ILVDA.gt.0) then
              X3 = -DFT
            else                       
              HDIFF=HNEW(J,I,K)-HNEW(J,I-1,K)
              X3=HDIFF*CC(J,I-1,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE FRONT FACE.
   90       IF(I.EQ.NROW) GO TO 120
            IF(IBOUND(J,I+1,K).EQ.0) GO TO 120
            if(ILVDA.gt.0) then
              X4 = DFB
            else             
              HDIFF=HNEW(J,I,K)-HNEW(J,I+1,K)
              X4=HDIFF*CC(J,I,K)
            endif  
C
C--CALCULATE FLOW THROUGH THE UPPER FACE
  120       IF(K.EQ.1) GO TO 150
            IF (IBOUND(J,I,K-1).EQ.0) GO TO 150
            HD=HNEW(J,I,K)
            IF(LTHUF(K).EQ.0) GO TO 122
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K)-1)
            IF(TMP.LT.TOP) HD=TOP
  122       HDIFF=HD-HNEW(J,I,K-1)
            X5=HDIFF*CV(J,I,K-1)
C
C--CALCULATE FLOW THROUGH THE LOWER FACE.
  150       IF(K.EQ.NLAY) GO TO 180
            IF(IBOUND(J,I,K+1).EQ.0) GO TO 180
            HD=HNEW(J,I,K+1)
            IF(LTHUF(K+1).EQ.0) GO TO 152
            TMP=HD
            TOP=BOTM(J,I,LBOTM(K+1)-1)
            IF(TMP.LT.TOP) HD=TOP
  152       HDIFF=HNEW(J,I,K)-HD
            X6=HDIFF*CV(J,I,K)
C
C--SUM UP FLOWS THROUGH SIX SIDES OF CONSTANT HEAD CELL.
  180       BUFF(J,I,K)=X1+X2+X3+X4+X5+X6
C
          ENDDO
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NCNH
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NCNH
      ENDIF
C
C--IF THERE ARE NO CONSTANT-HEAD CELLS THEN SKIP
      IF(NCNH.LE.0) GOTO 1000
C
C--WRITE CONSTANT-HEAD CELL LOCATIONS AND RATES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,K).GE.0) CYCLE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IUMT3D)   K,I,J,BUFF(J,I,K)
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IUMT3D,*) K,I,J,BUFF(J,I,K)
            ENDIF              
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
 1000 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE LMT7WEL7(IUNITUPW,ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE WELL CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from  Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,BOTM,LBOTM,HNEW
      USE GWFWELMODULE,ONLY:NWELLS,WELL,PSIRAMP
      USE GWFUPWMODULE,ONLY:LAYTYPUPW
      CHARACTER*16 TEXT
      double precision bbot, Hh, cof1, cof2, cof3, Qp, x, s
      double precision ttop
C      
C--SET POINTERS FOR THE CURRENT GRID   
      CALL SGWF2WEL7PNT(IGRID)
C      
      TEXT='WEL'   
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NWELLS
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NWELLS
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NWELLS.LE.0) GO TO 9999
C
C--WRITE WELL LOCATION AND RATE ONE AT A TIME
      DO L=1,NWELLS
        IL=WELL(1,L)
        IR=WELL(2,L)
        IC=WELL(3,L)
C
C--IF CELL IS EXTERNAL Q=0
        Q=ZERO
        IF(IBOUND(IC,IR,IL).GT.0) Q=WELL(4,L)
        IF ( LAYTYPUPW(il).GT.0 ) THEN
          bbot = Botm(IC, IR, Lbotm(IL))
          ttop = Botm(IC, IR, Lbotm(IL)-1)
          Hh = HNEW(ic,ir,il)
          x = (Hh-bbot)
          s = PSIRAMP
          s = s*(Ttop-Bbot)
          aa = -1.0d0/(s**2.0d0)
          b = 2.0d0/s
          cof1 = x**2.0D0
          cof2 = -(2.0D0*x)/(s**3.0D0)
          cof3 = 3.0D0/(s**2.0D0)
          Qp = cof1*(cof2+cof3)
          IF ( x.LT.0.0D0 ) THEN
            Qp = 0.0D0
          ELSEIF ( x-s.GT.-1.0e-14 ) THEN
            Qp = 1.0D0
          END IF
          IF ( Qp.LT.1.0 ) THEN
            Q = Q*Qp
          END IF
        END IF
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q
        ENDIF
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7DRN7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ********************************************************************
C SAVE DRAIN CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ********************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,BUFF
      USE GWFDRNMODULE,ONLY:NDRAIN,DRAI
      CHARACTER*16 TEXT
      DOUBLE PRECISION HHNEW,EEL,CCDRN,CEL,QQ
C    
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2DRN7PNT(IGRID)
C      
      TEXT='DRN'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NDRAIN
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NDRAIN
      ENDIF
C
C--IF THERE ARE NO DRAINS THEN SKIP
      IF(NDRAIN.LE.0) GO TO 9999
C
C--FOR EACH DRAIN ACCUMULATE DRAIN FLOW
      DO L=1,NDRAIN
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
        IL=DRAI(1,L)
        IR=DRAI(2,L)
        IC=DRAI(3,L)
        QQ=ZERO
C
C--CALCULATE Q FOR ACTIVE CELLS
        IF(IBOUND(IC,IR,IL).GT.0) THEN
C
C--GET DRAIN PARAMETERS FROM DRAIN LIST.
          EL=DRAI(4,L)
          EEL=EL
          C=DRAI(5,L)
          CCDRN=C
          HHNEW=HNEW(IC,IR,IL)
          CEL=C*EL
C
C--IF HEAD LOWER THAN DRAIN THEN FORGET THIS CELL.
C--OTHERWISE, CALCULATE Q=C*(EL-HHNEW).
          IF(HHNEW.GT.EEL) QQ=CEL - CCDRN*HHNEW
        ENDIF
        Q=QQ
C
C--WRITE DRAIN LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D)   IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q
        ENDIF  
C        
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7RIV7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE RIVER CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW
      USE GWFRIVMODULE,ONLY:NRIVER,RIVR
      CHARACTER*16 TEXT      
      DOUBLE PRECISION HHNEW,CHRIV,RRBOT,CCRIV
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2RIV7PNT(IGRID)      
C      
      TEXT='RIV'      
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NRIVER
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NRIVER
      ENDIF
C
C--IF NO REACHES SKIP
      IF(NRIVER.LE.0) GO TO 9999
C
C--FOR EACH RIVER REACH ACCUMULATE RIVER FLOW
      DO L=1,NRIVER
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING REACH.
        IL=RIVR(1,L)
        IR=RIVR(2,L)
        IC=RIVR(3,L)
C
C--IF CELL IS EXTERNAL RATE=0
        IF(IBOUND(IC,IR,IL).LE.0) THEN
          RATE=ZERO
C
C--GET RIVER PARAMETERS FROM RIVER LIST.
        ELSE
          HRIV=RIVR(4,L)
          CRIV=RIVR(5,L)
          RBOT=RIVR(6,L)
          HHNEW=HNEW(IC,IR,IL)
          CHRIV=CRIV*HRIV
          CCRIV=CRIV
          RRBOT=RBOT
C
C--COMPARE HEAD IN AQUIFER TO BOTTOM OF RIVERBED.
C
C--AQUIFER HEAD > BOTTOM THEN RATE=CRIV*(HRIV-HNEW).
          IF(HHNEW.GT.RRBOT) RATE=CHRIV-CCRIV*HHNEW
C
C--AQUIFER HEAD < BOTTOM THEN RATE=CRIV*(HRIV-RBOT)
          IF(HHNEW.LE.RRBOT) RATE=CRIV*(HRIV-RBOT)
        ENDIF
C
C--WRITE RIVER REACH LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,RATE
        ENDIF
C        
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7RCH7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *******************************************************************
C SAVE RECHARGE LAYER LOCATION AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C *******************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,BUFF
      USE GWFRCHMODULE,ONLY:NRCHOP,RECH,IRCH
      CHARACTER*16 TEXT
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2RCH7PNT(IGRID)   
C         
      TEXT='RCH'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
      ENDIF
C
C--CLEAR THE BUFFER.
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--IF NRCHOP=1 RECH GOES INTO LAYER 1.
      IF(NRCHOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) ((IL,J=1,NCOL),I=1,NROW)
C
C--STORE RECH RATE IN BUFF FOR ACTIVE CELLS
        DO I=1,NROW
          DO J=1,NCOL
            IF(IBOUND(J,I,1).GT.0) BUFF(J,I,1)=RECH(J,I)
          ENDDO
        ENDDO
        IF(ILMTFMT.EQ.0) THEN 
          WRITE(IUMT3D)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ENDIF
C
C--IF NRCHOP=2 OR 3 RECH IS IN LAYER SHOWN IN INDICATOR ARRAY(IRCH).
      ELSEIF(NRCHOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D)   ((IRCH(J,I),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((IRCH(J,I),J=1,NCOL),I=1,NROW)
        ENDIF  
C
C--STORE RECH RATE IN BUFF FOR ACTIVE CELLS
        DO I=1,NROW
          DO J=1,NCOL
            IL=IRCH(J,I)
            IF(IL.EQ.0) CYCLE
            IF(IBOUND(J,I,IL).GT.0) THEN
              BUFF(J,I,1)=RECH(J,I)
            ENDIF
          ENDDO
        ENDDO
        IF(ILMTFMT.EQ.0) THEN 
          WRITE(IUMT3D)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
        ENDIF  
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT7EVT7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ******************************************************************
C SAVE EVAPOTRANSPIRATION LAYER LOCATION AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C ******************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,BUFF      
      USE GWFEVTMODULE,ONLY:NEVTOP,EVTR,EXDP,SURF,IEVT
      CHARACTER*16 TEXT
      DOUBLE PRECISION QQ,HH,XX,DD,SS,HHCOF,RRHS      
C   
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2EVT7PNT(IGRID)
C            
      TEXT='EVT'
      ZERO=0.      
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
      ENDIF
C
C--CLEAR THE BUFFER.
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO
        ENDDO
      ENDDO   
C
C--PROCESS EACH HORIZONTAL CELL LOCATION
C--AND STORE ET RATES IN BUFFER (IC,IR,1)
      DO IR=1,NROW
        DO IC=1,NCOL
C
C--IF OPTION 1 SET THE LAYER INDEX EQUAL TO 1
          IF(NEVTOP.EQ.1) THEN
            IL=1
C
C--IF OPTION 2 OR 3 GET LAYER INDEX FROM IEVT ARRAY
          ELSEIF(NEVTOP.NE.1) THEN
            IL=IEVT(IC,IR)
            IF(IL.EQ.0) CYCLE
          ENDIF
C
C--IF CELL IS EXTERNAL THEN IGNORE IT.
          IF(IBOUND(IC,IR,IL).LE.0) CYCLE
          C=EVTR(IC,IR)
          S=SURF(IC,IR)
          SS=S
          HH=HNEW(IC,IR,IL)
C
C--IF AQUIFER HEAD => SURF,SET Q=MAX ET RATE
          IF(HH.GE.SS) THEN
            QQ=-C
C
C--IF DEPTH=>EXTINCTION DEPTH, ET IS 0
C--OTHERWISE, LINEAR RANGE: Q=-HNEW*EVTR/EXDP -EVTR +EVTR*SURF/EXDP
          ELSE
            X=EXDP(IC,IR)
            XX=X
            DD=SS-HH
            IF(DD.GE.XX) THEN
              QQ=ZERO
            ELSE
              HHCOF=-C/X
              RRHS=(C*S/X)-C
              QQ= HH*HHCOF + RRHS
            ENDIF
          ENDIF
C
C--ADD Q TO BUFFER 1
          BUFF(IC,IR,1)=QQ
        ENDDO
      ENDDO
C
C--RECORD THEM.
      IF(NEVTOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) ((IL,J=1,NCOL),I=1,NROW)
      ELSEIF(NEVTOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   ((IEVT(J,I),J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) ((IEVT(J,I),J=1,NCOL),I=1,NROW)
      ENDIF
C
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT7GHB7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *****************************************************************
C SAVE HEAD-DEPENDENT BOUNDARY CELL LOCATIONS AND VOLUMETRIC FLOW
C RATES FOR USE BY MT3D.
C *****************************************************************
C Modified from Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,BUFF
      USE GWFGHBMODULE,ONLY:NBOUND,BNDS
      CHARACTER*16 TEXT
      DOUBLE PRECISION CCGHB,CHB
C
C--SET POINTERS FOR THE CURRENT GRID     
      CALL SGWF2GHB7PNT(IGRID)
C      
      TEXT='GHB'
      ZERO=0.      
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NBOUND
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NBOUND
      ENDIF
C
C--IF NO BOUNDARIES THEN SKIP
      IF(NBOUND.LE.0) GO TO 9999
C
C--FOR EACH GENERAL HEAD BOUND ACCUMULATE FLOW INTO AQUIFER
      DO L=1,NBOUND
C
C--GET LAYER, ROW AND COLUMN OF EACH GENERAL HEAD BOUNDARY.
        IL=BNDS(1,L)
        IR=BNDS(2,L)
        IC=BNDS(3,L)
C
C--RATE=0 IF IBOUND=<0
        RATE=ZERO
        IF(IBOUND(IC,IR,IL).GT.0) THEN
C
C--GET PARAMETERS FROM BOUNDARY LIST.          
          HB=BNDS(4,L)
          C=BNDS(5,L)
          CCGHB=C          
          CHB=C*HB
C
C--CALCULATE THE FOW RATE INTO THE CELL
          RATE= CHB - CCGHB*HNEW(IC,IR,IL)
        ENDIF
C
C--WRITE HEAD DEP. BOUND. LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,RATE
        ENDIF
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7FHB7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C **********************************************************************
C SAVE SPECIFIED-FLOW CELL LOCATIONS AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C **********************************************************************
C Modified from Leake and Lilly (1997), and Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND     
      USE GWFFHBMODULE,ONLY:NFLW,IFLLOC,BDFV
      CHARACTER*16 TEXT
C   
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2FHB7PNT(IGRID)
C      
      TEXT='FHB'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NFLW
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NFLW
      ENDIF
C
C--IF NO SPECIFIED-FLOW CELL, RETURN
      IF(NFLW.LE.0) GO TO 9999
C
C--PROCESS SPECIFIED-FLOW CELLS ONE AT A TIME.

      DO L=1,NFLW
C
C--GET LAYER, ROW, AND COLUMN NUMBERS
        IR=IFLLOC(2,L)
        IC=IFLLOC(3,L)
        IL=IFLLOC(1,L)
        Q=ZERO
C
C--GET FLOW RATE FROM SPECIFIED-FLOW LIST
        IF(IBOUND(IC,IR,IL).GT.0) Q=BDFV(1,L)
C
C--WRITE SPECIFIED-FLOW CELL LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,Q
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q
        ENDIF
      ENDDO
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7RES7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C **********************************************************************
C SAVE RESERVOIR CELL LOCATIONS AND VOLUMETRIC FLOW RATES
C FOR USE BY MT3D.
C **********************************************************************
C Modified from Fenske et al., (1996), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL ,      ONLY: HNEW,IBOUND,BUFF,NCOL,NROW,NLAY 
      USE GWFRESMODULE, ONLY: NRES,NRESOP,IRES,IRESL,BRES,CRES,
     &                        BBRES,HRES  
      CHARACTER*16 TEXT    
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2RES7PNT(IGRID)            
C      
      TEXT='RES'
      ZERO=0.
C
C--CLEAR BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO
        ENDDO
      ENDDO
C
C--FOR EACH RESERVOIR REACH ACCUMULATE RESERVOIR FLOW
      DO 200 I=1,NROW
      DO 190 J=1,NCOL
      NR=IRES(J,I)
      IF(NR.LE.0) GO TO 190
      IF(NR.GT.NRES) GO TO 190
      IR=I
      IC=J
C
C--FIND LAYER NUMBER FOR RESERVOIR CELL
      IF(NRESOP.EQ.1) THEN
       IL=1
      ELSE IF(NRESOP.EQ.2) THEN
       IL=IRESL(IC,IR)
      ELSE
       DO 60 K=1,NLAY
       IL=K
C--UPPERMOST ACTIVE CELL FOUND, SAVE LAYER INDEX IN 'IL'
       IF(IBOUND(IC,IR,IL).GT.0) GO TO 70
C--SKIP THIS CELL IF VERTICAL COLUMN CONTAINS A CONSTANT-
C--HEAD CELL ABOVE RESERVOIR LOCATION
       IF(IBOUND(IC,IR,IL).LT.0) GO TO 190
   60  CONTINUE
       GO TO 190
      ENDIF
C
C--IF THE CELL IS EXTERNAL SKIP IT.
      IF(IBOUND(IC,IR,IL).LE.0) GO TO 190
C
C--IF RESERVOIR STAGE IS BELOW RESERVOIR BOTTOM, SKIP IT
   70 HR=HRES(NR)
      IF(HR.LE.BRES(IC,IR))  GO TO 190
C--SINCE RESERVOIR IS ACTIVE AT THIS LOCATION,
C--GET THE RESERVOIR DATA.
      CR=CRES(IC,IR)
      RBOT=BBRES(IC,IR)
      HHNEW=HNEW(IC,IR,IL)
C
C--COMPUTE RATE OF FLOW BETWEEN GROUND-WATER SYSTEM AND RESERVOIR.
C
C--GROUND-WATER HEAD > BOTTOM THEN RATE=CR*(HR-HNEW).
      IF(HHNEW.GT.RBOT) RATE=CR*(HR-HHNEW)
C
C--GROUND-WATER HEAD < BOTTOM THEN RATE=CR*(HR-RBOT)
      IF(HHNEW.LE.RBOT) RATE=CR*(HR-RBOT)
C
C--ADD RATE TO BUFFER.
      BUFF(IC,IR,IL)=BUFF(IC,IR,IL)+RATE
  190 CONTINUE
  200 CONTINUE
C
C--COUNT RES CELLS WITH NONZERO FLOW RATE
      NTEMP=0
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            IF(IBOUND(IC,IR,IL).LE.0) CYCLE
            IF(BUFF(IC,IR,IL).NE.ZERO) THEN
              NTEMP=NTEMP+1
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NTEMP
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NTEMP
      ENDIF
C
C--IF NO RES CELLS WITH NONZERO Q, RETURN
      IF(NTEMP.EQ.0) GO TO 9999
C
C--WRITE RES CELL LOCATION AND FLOW RATE
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            IF(IBOUND(IC,IR,IL).LE.0) CYCLE
            RATE=BUFF(IC,IR,IL)
            IF(RATE.NE.ZERO) THEN
              IF(ILMTFMT.EQ.0) THEN
                WRITE(IUMT3D)   IL,IR,IC,RATE
              ELSEIF(ILMTFMT.EQ.1) THEN
                WRITE(IUMT3D,*) IL,IR,IC,RATE
              ENDIF  
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7STR7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C **********************************************************************
C SAVE STREAM CELL LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C **********************************************************************
C Modified from Prudic (1989), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND      
      USE GWFSTRMODULE,ONLY:NSTREM,STRM,ISTRM
      CHARACTER*16 TEXT     
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2STR7PNT(IGRID)    
C                    
      TEXT='STR'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NSTREM
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NSTREM
      ENDIF
C
C--IF NO REACHES, SKIP
      IF(NSTREM.EQ.0) GO TO 9999
C
C--FOR EACH STREAM REACH GET LEAKAGE TO OR FROM IT
      DO L=1,NSTREM
C
C--GET REACH LOCATION AND FLOW RATE
        IL=ISTRM(1,L)
        IR=ISTRM(2,L)
        IC=ISTRM(3,L)
        IF(IBOUND(IC,IR,IL).LE.0) THEN
          RATE=ZERO
        ELSE
          RATE=STRM(11,L)
        ENDIF
C
C--WRITE STREAM REACH LOCATION AND RATE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,RATE
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,RATE
        ENDIF
C        
      ENDDO
C
C--NORMAL RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7MNW7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE MNW LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from MNW by Halford and Hanson (2002)
C last modification: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND
      USE GWFMNW1MODULE,ONLY:NWELL2,WELL2
      CHARACTER*16 TEXT
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2MNW1PNT(IGRID)
C      
      TEXT='MNW'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NWELL2
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NWELL2
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NWELL2.LE.0) GO TO 9999
C
C--PROCESS WELL LIST
      DO m = 1,nwell2
        n = ifrl( well2(1,m) )
        il = (n-1) / (ncol*nrow) + 1
        ir = mod((n-1),ncol*nrow)/ncol + 1
        ic = mod((n-1),ncol) + 1
        IDwell = ifrl(well2(18,m))  !IDwell in well2(18,m); cdl 4/19/05
        Q = well2(17,m)
C
C--IF CELL IS EXTERNAL Q=0
        IF(IBOUND(IC,IR,IL).LE.0) Q=ZERO
C
C--DUMMY VARIABLE QSW NOT USED, SET TO 0
        QSW=ZERO
C
C--SAVE TO OUTPUT FILE
        IF(ILMTFMT.EQ.0) THEN
          WRITE(IUMT3D) IL,IR,IC,Q,IDwell,QSW
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) IL,IR,IC,Q,IDwell,QSW
        ENDIF
      ENDDO
C
C--RETURN
 9999 RETURN
      END
C
C
C
      SUBROUTINE LMT7MNW2(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE MNW LOCATIONS AND VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C *********************************************************************
C Modified from MNW by Halford and Hanson (2002)
C last modification: 08-08-2008
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND
      USE GWFMNW2MODULE,ONLY:NMNWVL,MNWMAX,MNW2,MNWNOD
      CHARACTER*16 TEXT
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2MNW2PNT(IGRID)
C      
      TEXT='MNW'
      qqq1=0.
      qqq2=0.
      IOUT = IUMT3D
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IOUT) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NUMMNW2
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IOUT,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IOUT,*) TEXT,NUMMNW2
      ENDIF
C
C--IF THERE ARE NO WELLS RETURN
      IF(NUMMNW2.LE.0) RETURN
C
C--PROCESS WELL LIST
      iii=0
      do iw=1,MNWMAX
        if (MNW2(1,iw).EQ.1) then
          firstnode=MNW2(4,iw)
          lastnode=MNW2(4,iw)+ABS(MNW2(2,iw))-1
          do INODE=firstnode,lastnode
            iii=iii+1
            il=MNWNOD(1,INODE)              
            ir=MNWNOD(2,INODE)              
            ic=MNWNOD(3,INODE)              
            Q = MNWNOD(4,INODE) !well2(17,m)
C
C--IF CELL IS EXTERNAL Q=0
            IF(IBOUND(ic,ir,il).LE.0) Q=0.
            if(q.le.0.) then 
              qqq1=qqq1+q
            else
              qqq2=qqq2+q
            endif
C
C--DUMMY VARIABLE QSW NOT USED, SET TO 0
            QSW=0.
C
C--SAVE TO OUTPUT FILE
            IF(ILMTFMT.EQ.0) THEN
              WRITE(IOUT) IL,IR,IC,Q,INODE,QSW
            ELSEIF(ILMTFMT.EQ.1) THEN
              WRITE(IOUT,*) IL,IR,IC,Q,INODE,QSW
            ENDIF
C
          ENDDO
        endif
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT7ETS7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ********************************************************************
C SAVE SEGMENTED EVAPOTRANSPIRATION LAYER INDICES (IF NLAY>1) AND
C VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ********************************************************************
C Modified from Banta (2000), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL ,      ONLY: HNEW,IBOUND,BUFF,NCOL,NROW,NLAY      
      USE GWFETSMODULE, ONLY: NETSOP,NETSEG,IETS,ETSR,ETSX,ETSS,
     &                        PXDP,PETM
      CHARACTER*16 TEXT
      DOUBLE PRECISION QQ,HH,SS,DD,XX,HHCOF,RRHS,PXDP1,PXDP2
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2ETS7PNT(IGRID)
C      
      TEXT='ETS'
      ZERO=0.      
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT
      ENDIF      
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=ZERO
          ENDDO   
        ENDDO   
      ENDDO   
C
C--PROCESS EACH HORIZONTAL CELL LOCATION
      DO IR=1,NROW
        DO IC=1,NCOL
C
C--SET THE LAYER INDEX EQUAL TO 1.
          IL=1
C
C--IF OPTION 2 IS SPECIFIED THEN GET LAYER INDEX FROM IETS ARRAY
          IF (NETSOP.EQ.2) IL=IETS(IC,IR)
          IF (IL.EQ.0) CYCLE
C
C--IF CELL IS EXTERNAL THEN IGNORE IT.
          IF (IBOUND(IC,IR,IL).LE.0) CYCLE
C          
          C=ETSR(IC,IR)
          S=ETSS(IC,IR)
          SS=S
          HH=HNEW(IC,IR,IL)
C
C--IF HEAD IN CELL => ETSS,SET Q=MAX ET RATE.
          IF (HH.GE.SS) THEN
            QQ=-C
          ELSE
C
C--IF DEPTH=>EXTINCTION DEPTH, ET IS 0.
            X=ETSX(IC,IR)
            XX=X
            DD=SS-HH
            IF (DD.LT.XX) THEN
C--VARIABLE RANGE.  CALCULATE Q DEPENDING ON NUMBER OF SEGMENTS
C
              IF (NETSEG.GT.1) THEN
C               DETERMINE WHICH SEGMENT APPLIES BASED ON HEAD, AND
C               CALCULATE TERMS TO ADD TO RHS AND HCOF
C
C               SET PROPORTIONS CORRESPONDING TO ETSS ELEVATION
                PXDP1 = 0.0
                PETM1 = 1.0
                DO ISEG = 1,NETSEG
C                 SET PROPORTIONS CORRESPONDING TO LOWER END OF
C                 SEGMENT
                  IF (ISEG.LT.NETSEG) THEN
                    PXDP2 = PXDP(IC,IR,ISEG)
                    PETM2 = PETM(IC,IR,ISEG)
                  ELSE
                    PXDP2 = 1.0
                    PETM2 = 0.0
                  ENDIF
                  IF (DD.LE.PXDP2*XX) THEN
C                   HEAD IS IN DOMAIN OF THIS SEGMENT
                    EXIT
                  ENDIF
C                 PROPORTIONS AT LOWER END OF SEGMENT WILL BE FOR
C                 UPPER END OF SEGMENT NEXT TIME THROUGH LOOP
                  PXDP1 = PXDP2
                  PETM1 = PETM2
                ENDDO   
C--CALCULATE ET RATE BASED ON SEGMENT THAT APPLIES AT HEAD
C--ELEVATION
                HHCOF = -(PETM1-PETM2)*C/((PXDP2-PXDP1)*X)
                RRHS = -HHCOF*(S-PXDP1*X) - PETM1*C
              ELSE
C--SIMPLE LINEAR RELATION.  Q=-ETSR*(HNEW-(ETSS-ETSX))/ETSX, WHICH
C--IS FORMULATED AS Q= -HNEW*ETSR/ETSX + (ETSR*ETSS/ETSX -ETSR).
                HHCOF = -C/X
                RRHS = (C*S/X) - C
              ENDIF
              QQ = HH*HHCOF + RRHS
            ELSE
              QQ = ZERO
            ENDIF
          ENDIF  
C
C--ADD Q TO BUFFER.
          Q=QQ
          BUFF(IC,IR,1)=Q
        ENDDO   
      ENDDO   
C
C--RECORD THEM
      IF(NETSOP.EQ.1) THEN
        IL=1
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)  ((IL,J=1,NCOL),I=1,NROW)
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*)((IL,J=1,NCOL),I=1,NROW)
      ELSEIF(NETSOP.NE.1) THEN
        IF(ILMTFMT.EQ.0) THEN 
          WRITE(IUMT3D)   ((IETS(J,I),J=1,NCOL),I=1,NROW)
        ELSEIF(ILMTFMT.EQ.1) THEN
          WRITE(IUMT3D,*) ((IETS(J,I),J=1,NCOL),I=1,NROW)
        ENDIF  
      ENDIF
C
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D)   ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) ((BUFF(J,I,1),J=1,NCOL),I=1,NROW)
      ENDIF
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE LMT7DRT7(ILMTFMT,IUMT3D,KSTP,KPER,IGRID)
C ******************************************************************
C SAVE DRT (Drain with Return Flow) CELL LOCATIONS AND 
C VOLUMETRIC FLOW RATES FOR USE BY MT3D.
C ******************************************************************
C Modified from Banta (2000), Harbaugh (2005)
C last modified: 08-08-2008
C
      USE GLOBAL ,      ONLY: HNEW,IBOUND,NCOL,NROW,NLAY
      USE GWFDRTMODULE, ONLY: DRTF,NDRTCL,IDRTFL,NRFLOW
      CHARACTER*16 TEXT
      DOUBLE PRECISION HHNEW,EEL,CC,CEL,QQ,QQIN
C
C--SET POINTERS FOR THE CURRENT GRID
      CALL SGWF2DRT7PNT(IGRID)
C      
      TEXT='DRT'
      ZERO=0.
C
C--WRITE AN IDENTIFYING HEADER
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT,NDRTCL+NRFLOW
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT,NDRTCL+NRFLOW
      ENDIF      
C
C--IF THERE ARE NO DRAIN-RETURN CELLS, SKIP.
      IF (NDRTCL+NRFLOW.LE.0) GO TO 9999
C
C--LOOP THROUGH EACH DRAIN-RETURN CELL, CALCULATING FLOW.
      DO L=1,NDRTCL
C
C--GET LAYER, ROW & COLUMN OF CELL CONTAINING DRAIN.
        IL=DRTF(1,L)
        IR=DRTF(2,L)
        IC=DRTF(3,L)
        Q=ZERO
        ILR=0
        IF(IDRTFL.GT.0) THEN
          QIN=ZERO
          ILR=DRTF(6,L)
          IRR=DRTF(7,L)
          ICR=DRTF(8,L)
          IF(IBOUND(ICR,IRR,ILR).LE.0) ILR=0
        ENDIF                
C
C--IF CELL IS NO-FLOW OR CONSTANT-HEAD, IGNORE IT.
        IF (IBOUND(IC,IR,IL).LE.0) GOTO 99
C
C--GET DRAIN PARAMETERS FROM DRAIN-RETURN LIST.
        EL=DRTF(4,L)
        EEL=EL
        C=DRTF(5,L)
        HHNEW=HNEW(IC,IR,IL)
C
C--IF HEAD HIGHER THAN DRAIN, CALCULATE Q=C*(EL-HHNEW).
        IF(HHNEW.GT.EEL) THEN
          CC=C
          CEL=C*EL
          QQ=CEL - CC*HHNEW
          Q=QQ          
          IF(IDRTFL.GT.0) THEN           
            IF(ILR.NE.0) THEN
              RFPROP = DRTF(9,L)
              QQIN = RFPROP*(CC*HHNEW-CEL)
              QIN = QQIN
            ENDIF
          ENDIF
        ENDIF
   99   CONTINUE     
C
C--WRITE DRT LOCATION AND RATE (both host and recipient)
        mhost=0
        QSW=ZERO
C       main drain (host to recipient cell)
        IF(ILMTFMT.EQ.0) WRITE(IUMT3D)   IL,IR,IC,Q,mhost,QSW
        IF(ILMTFMT.EQ.1) WRITE(IUMT3D,*) IL,IR,IC,Q,mhost,QSW 
C       return flow recipient cell 
        if(IDRTFL.GT.0 .AND. ILR.GT.0) then
          mhost = ncol*nrow*(IL-1) + ncol*(IR-1) + IC
          IF(ILMTFMT.EQ.0) THEN
            WRITE(IUMT3D)   ILR,IRR,ICR,QIN,mhost,QSW            
          ELSEIF(ILMTFMT.EQ.1) THEN 
            WRITE(IUMT3D,*) ILR,IRR,ICR,QIN,mhost,QSW
          ENDIF
        endif
      ENDDO   
C
C--RETURN
 9999 RETURN
      END
C
C
      SUBROUTINE LMT7UZF1(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW THROUGH UNSATURATED CELL IN VERTICAL DIRECTION.
C THIS SUBROUTINE IS CALLED ONLY IF THE 'UZF' PACKAGE
C IS USED IN MODFLOW AND SOLUTE ROUTING IS ACTIVE IN 'UZF'.
C *********************************************************************
C
C last modified: 05-13-2010
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,HOLD,
     &                      BUFF,BOTM,DELR,DELC
      USE GWFBASMODULE,ONLY:DELT, HNOFLO
      USE GWFUZFMODULE,ONLY:IUZFBND, UZTHIT, UZFLIT, IUZHOLD,
     &                      UZSPIT, SEEPOUT
      CHARACTER*16 TEXT1, TEXT2, TEXT3, TEXT4
      REAL cellarea
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2UZF1PNT(IGRID)
C            
      TEXT1='WATER CONTENT'
      TEXT2='UZ FLUX'
      TEXT3='UZQSTO'
      TEXT4='GWQOUT'
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
      numcells = NCOL*NROW
C
C--FOR EACH CELL CALCULATE WATER CONTENT & STORE IN BUFFER
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
              IF( HNEW(J,I,K).LT.BOTM(J,I,K-1) )THEN
                BUFF(J,I,K)=UZTHIT(K,l)
              ELSEIF ( ABS(SNGL(HNEW(J,I,K))-HNOFLO).LT.1.0 ) THEN
                BUFF(J,I,K)=UZTHIT(K,l)
              END IF
            END IF
          END IF
        ENDDO
      END DO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT1
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT1
        WRITE(IUMT3D,*) BUFF
!        do k=1,nlay
!        do i=1,nrow
!        write(IUMT3D,101)(buff(j,i,k),j=1,ncol)
!        end do
!        end do
      ENDIF
!  101 format(10e12.5)
C
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
C
C--FOR EACH CELL CALCULATE FLUX THROUGH LOWER FACE & STORE IN BUFFER
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
!              IF( HNEW(J,I,K).LT.BOTM(J,I,K-1) ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=UZFLIT(K,l)*cellarea
                IF ( abs(BUFF(J,I,K)).LT.1.0e-10 )
     +               BUFF(J,I,K) = 0.0
!              ELSEIF ( ABS(SNGL(HNEW(J,I,K))-HNOFLO).LT.1.0 ) THEN
!                cellarea = DELR(J)*DELC(I)
!                BUFF(J,I,K)=UZFLIT(K,l)*cellarea
!              END IF
            END IF
          END IF
        ENDDO
      END DO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT2
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT2
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
C--FOR EACH CELL CALCULATE CHANGE IN STORAGE & STORE IN BUFFER
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
              IF( HNEW(J,I,K).LT.BOTM(J,I,K-1) ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=UZSPIT(K,l)*cellarea
              ELSEIF ( ABS(SNGL(HNEW(J,I,K))-HNOFLO).LT.1.0 ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=UZSPIT(K,l)*cellarea
              END IF
            END IF
          END IF
        ENDDO
      END DO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT3
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT3
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C
C--CLEAR THE BUFFER
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
C--FOR EACH CELL CALCULATE GW DISCHARGE TO LAND SURFACE & STORE IN BUFFER
      DO IR=1,NROW
        DO IC=1,NCOL
          IL = IUZFBND(IC,IR)
          IF( IUZFBND(IC,IR).NE.0 ) THEN
            BUFF(IC,IR,IL)=-SEEPOUT(IC,IR)
          END IF
        ENDDO
      END DO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT4
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT4
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
      RETURN
      END
      SUBROUTINE LMT7UZFET(ILMTFMT,ISSMT3D,IUMT3D,KSTP,KPER,IGRID)
C *********************************************************************
C SAVE FLOW THROUGH UNSATURATED CELL IN VERTICAL DIRECTION.
C THIS SUBROUTINE IS CALLED ONLY IF THE 'UZF' PACKAGE
C IS USED IN MODFLOW AND SOLUTE ROUTING IS ACTIVE IN 'UZF'.
C *********************************************************************
C
C last modified: 05-13-2010
C
      USE GLOBAL,      ONLY:NCOL,NROW,NLAY,IBOUND,HNEW,HOLD,
     &                      BUFF,BOTM,DELR,DELC
      USE GWFBASMODULE,ONLY:DELT, HNOFLO
      USE GWFUZFMODULE,ONLY:IUZFBND, GRIDET, IUZHOLD, IETFLG, GWET,
     &                      SEEPOUT
      CHARACTER*16 TEXT1, TEXT2
      REAL cellarea
      IF ( IETFLG.LE.0 ) RETURN
C
C--SET POINTERS FOR THE CURRENT GRID      
      CALL SGWF2UZF1PNT(IGRID)
C            
      TEXT1='UZ-ET'

C
C--CLEAR THE BUFFER FOR UZ ET
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
      numcells = NCOL*NROW
C
C--FOR EACH CELL CALCULATE UZ ET & STORE IN BUFFER
      DO K = 1, NLAY
        l = 0
        DO ll = 1, numcells
          I = IUZHOLD(1, ll)
          J = IUZHOLD(2, ll)
          IF( IUZFBND(J,I).NE.0 ) THEN
            l = l + 1
            IF( K.GE.IUZFBND(J,I) ) THEN
              IF( HNEW(J,I,K).LT.BOTM(J,I,K-1) )THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=-GRIDET(J,I,K)*cellarea/DELT
              ELSEIF ( ABS(SNGL(HNEW(J,I,K))-HNOFLO).LT.1.0 ) THEN
                cellarea = DELR(J)*DELC(I)
                BUFF(J,I,K)=-GRIDET(J,I,K)*cellarea/DELT
                GRIDET(J,I,K) = 0.0
              END IF
            END IF
          END IF
        ENDDO
      END DO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT1
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT1
        WRITE(IUMT3D,*) BUFF
      ENDIF
C
C--CLEAR THE BUFFER FOR GW ET
      TEXT2='GW-ET'
      DO IL=1,NLAY
        DO IR=1,NROW
          DO IC=1,NCOL
            BUFF(IC,IR,IL)=0.0
          ENDDO   
        ENDDO   
      ENDDO
      numcells = NCOL*NROW
C
C--FOR EACH CELL CALCULATE GW ET & STORE IN BUFFER
      DO I=1,NROW
        DO J=1,NCOL
          K = IUZFBND(J,I)
          IF ( K.NE.0 ) THEN
            IF ( IBOUND(J,I,K).GT.0 ) THEN
              BUFF(J,I,K)=-GWET(J,I)
            END IF
          END IF
        ENDDO
      ENDDO
C
C--RECORD CONTENTS OF BUFFER.
      IF(ILMTFMT.EQ.0) THEN
        WRITE(IUMT3D) KPER,KSTP,NCOL,NROW,NLAY,TEXT2
        WRITE(IUMT3D) BUFF
      ELSEIF(ILMTFMT.EQ.1) THEN
        WRITE(IUMT3D,*) KPER,KSTP,NCOL,NROW,NLAY
        WRITE(IUMT3D,*) TEXT2
        WRITE(IUMT3D,*) BUFF
      ENDIF
      RETURN
      END
