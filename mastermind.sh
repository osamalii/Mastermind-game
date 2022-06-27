MasterMind.sh                                                                                       0000777 0001750 0001750 00000031701 13572503721 013327  0                                                                                                    ustar   osamali                         osamali                                                                                                                                                                                                                currentUser=false
cc=0
win=false
newgame=false

#ctr+z afficher le menu
trap lancerMenu 20
#les option du menu
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Register"
	echo "2. Login"
	echo "3. Start"
  echo "4. Continue"
  echo "5. Save"
	echo "6. Description"
	echo "7. vainqueurs"
  echo "8. Quit"
}
#traitemnet du choix de lutilisateur
read_options(){
	local choice
	read -p "Enter choice [ 1 - 8] " choice
	case $choice in
		1) register ;;
		2) login ;;
    3) startup ;;
    5) savegame ;;
    4) continugame ;;
		6) desc ;;
		7) afficherVainq ;;
		8) exit 0 ;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
  exit 0
}
lancerMenu(){
	#le menu sera toujours affichier sauf si une fonction l'interompe (selon le choix de lutilisateur)
  while true
do
  show_menus
	read_options
done
}

#Descption du jeu , du reglement, et comment jouer
desc(){
	clear
	echo 'MasterMind est un jeu de logic et hasard en meme temps
le jeu consiste a trouver la combinaison cherchee sans depasser 10 essai
les combinaisons sont constituees de couleurs (4 parmi 8 si le niveau est simple et 5 parmi 10 sinon):
		N: noir (simple et difficile).
		B: blanc (simple et difficile).
  	R: rouge (simple et difficile).
		V: vert (simple et difficile).
		M: maron (simple et difficile).
		G: gris (simple et difficile).
		J: jaune (simple et difficile).
		O: orange (simple et difficile).
		C: cyan (difficile).
		A: aqua (difficile).
	*chaque couleur est representee avec sa premiere lettre.
Afin que vous puissez jouer il faut creer un compte(1. sur le menu) en suite
vous pouvez sauvegarder (5.sur le menu) une combinaison et la rejouer (4. sur le menu)
plutard ou vous pouvez tout simplement commencer une nouvelle combinaison (3.sur le menu)
NOTE:
   - dans une combinaison les couleurs ne se repetent pas.
	 - vous ne pouvez sauvegarder qu une seule combinaison.
	 - pour revenir au menu pricipal appuiez sur ctr+z.'
echo appuiez sur q pour Quiter ce menu
read o
while [[ $o != q ]]; do
	read o
done

lancerMenu
}
#afficher les gagnant stocke de le repertoir vainqueurs
afficherVainq(){
	clear
	while read p; do
			echo $p
	done <./vainqueurs/winers
	echo appuiez sur q pour Quiter
	read d
	while [[ $d != q ]]; do
		read d
	done
lancerMenu
}

#cree un compte
register(){
  clear
  echo 'Donner un nom dutilisateur:'
  read username
  echo 'Donner un mot de passe'
  read passwd
  FILE=./joueurs/$username
  touch $FILE
	#le fichier ou on va stocker les coordonees de lutilisateur
  echo $username'+'$passwd > $FILE
  sleep 2
	#apres linscription on revient au menu
  lancerMenu
}
#se connecte un compte deja cree par un utilisateur
login(){
  clear
  if [ $currentUser = true ] ; then
		#si le joueur est deja on l affiche
        echo 'vous etes deja connecte'
        sleep 1
	  #puis on revient au menu principale
        lancerMenu
  else
        echo 'Donner votre nom dutilisateur:'
        read username
        FILE=./joueurs/$username
        if [ -f $FILE ]; then
					#si le username done par l utilisateur est present dans le fichier des utilisateur:
            echo 'saisir votre mot de passe'
            read passwd
            vipasswd=$(cut -d'+' -f2 $FILE)
						#si le mot de passe ne match pas le mot de passe donne a linscription on demande le saisir une autre fois jusqu il le match
            while [ $vipasswd != $passwd ]
            do
              echo 'Incorrect password'
              echo 'Donner un mot de passe'
              read passwd
            done
						#modifie la varibale currentuser pour l utilise dans d autre fonction
            currentUser=true
            echo 'you are logged in'
        else
            echo 'utilisateur introuvable'
        fi
        sleep 1
      lancerMenu
  fi
}
startup(){
	#on test si il est connecte ceci est nessecaire selement au cas ou le joueur a gagne pour le considere parmi les vainqueurs
  if [[ $currentUser = true ]] ; then
       clear
       echo choisiser le niveau ...
       echo 1. simple
       echo 2. difficile
       echo 3. retour au menu principale
# on demande de choisir le niveau soit simple soit difficile
       local niveau
       read -p "Enter choice [ 1 - 3] " niveau
       case $niveau in
         1) selectSimple ;;
         2) selectDifficile ;;
         3) lancerMenu ;;
         *) echo -e "${RED}Error...${STD}" && sleep 2
       esac
       exit 0
  else
    clear
     echo you must be logged in to startup
     sleep 1
     lancerMenu

fi


}

selectSimple(){
  sleep 1
  clear
	#le premier paramete : combien de nombre la combinaison sera composee
	# le deuxieme :les couleurs du combinaison seron parmi la valeur de ce parametre
	#le troisieme : le fichier ou les couleur sont placees
  createcombi 4 8 'easy'
	#le premier paramete : le fichier ou la combinaison cherchee est placee
	# le deuxieme :combien de couleur on va lire de l utilisateur
	#le troisieme : le fichier ou les couleur sont placees
	#le quatrieme: ou les faux combinaison entrees par l utilisateur seron placees
  Saisircombi input 4 'easy' played
}
selectDifficile(){
  sleep 1
  clear
  createcombi 5 10 'advanced'
  Saisircombi input 5 'advanced' played
}

createcombi(){
	#vider le fichier a chaque fois le joueur decide de jouer a une nouvelle combinaisons
	#input: contient la combinaison chercher
   > ./input
	 #vider les faux combinaison entrees par le joueur
	 > played
	 #mentione que le jouer a decide de jouer a une nouvelle combinaison cet variable sera condition
	 #si le joueurs veut sauvegarder une combinaison si elle est egale a false cad il n ya rein a sauvegarde
	 newgame=true
	 #le hasar commence ici : ou la machine choisie au hasad des nombre et a la fin ces nombre represente le nombre de la ligne ou une couleurs est stockee dans le fichier "easy" ou "advanced" selon le niveau
$(shuf -i 1-$2 -n $1 -o ./index)
  for i in `seq 1 $1`
do
  index=$(head -n+$i ./index | tail -n+$i)
  #lire chaque ligne des nombre "nombre represente une couleur"
  echo $(head -n+$index ./$3 | tail -n+$index) >> ./input
	#recuperer la couleurs qui correspond
done
#initialiser le compteur qui sera limite a 10 : 10 chance pour trouver la combinaison chercher
echo 0 >> ./input
}
verifiercombi(){
	#on compte le nombre de difference entre les deux fichier et ceci representera le nombre des erreurs dans la combinaison donne par lutilisateur
  nnc=`expr $(grep -v -F -x -f userinput $1 | wc -l) - 1`
	#le nombre de ressemblance qui revient au nombre de couleurs bien placees
  nc=`expr $2  - $nnc`
   if [[ $nc -eq $2 ]]; then
		 #si le nombre de ressemblance est egal au combien la combinaison contient de couleurs on aura un gagnant
     echo ~you have WON~~
		 #on ajjoute un winner au vainqueurs
		 echo $username a gagne le $(date) >> ./vainqueurs/winers
     sleep 2
     win=true
		 #on modifie la variable win pour s arreter de demander du joueur d enter une combinaison
		 if [[ $1 = './sauvegarde/'$username ]]; then
			 #si il sagit d une combinaison deja sauvegder on la supprime parsqu elle n est plut utile
		 	rm -f ./sauvegarde/$username
		 fi
		 lancerMenu
		 #puis on revient au menu principale

   else
		 #si il ne sagit pas d un win on incrrement le conteur cad le joueur a epuise une chance
		 cc=`expr $cc + 1`
		 #on stock la fausse combinaison entree oar le joueur
		 #on la formate pour qu elle soit dans une seule ligne
     com=''
     for i in `seq 1 $2`
     do
       com=$com' '$(head -n+$i ./userinput | tail -n+$i)
     done
		 #on la stock dans le fichier played pour l afficher plutard ou la place dans lerepertoir joueurs si le joueru a decide de sauvegder
     echo '('$com')' $nc bien placees et $nnc elements mals palcees >> $3
		 #on modifie le compteur en l incrrementant
		 sed -i `expr $2 + 1`'s/.*/'$cc'/' $1
     #on affiche toutes les fausses combinaisons que le joueur avait deja entrees
		 afficherplateau $3
   fi
}

afficherplateau(){
	#on affiche tout simplement le contenu de fuchier ou on a stocke les fausses combinaison
	clear
	cat $1
	#calcluer combien de chance reste
	rest=`expr 10 - $(cat $1 | wc -l)`
	echo il vous reste $rest chance
}

Saisircombi(){
	#on recupre le compteur
	cc=$(tail -n-1 $1)
	#si le compteur est egal a 0 cad le joueur a eppuise ces chances il ne peu plus jouer a la current combinaison
	if [[ $cc -ge 10 ]]; then
		clear
		echo vous avez epuiser votre chance pour jouer
		sleep 1
		lancerMenu
		#si il sagit d une suite on efface la combinaison elle est inutil parecq le joueur a epuiser ces chance
		   if [[ $1 = './sauvegarde/'$username ]]; then
		    rm -f ./sauvegarde/$username
				rm -f ./sauvegarde/$username'played'
		   fi
	else
		while [[ $cc -lt 10 && $win = false ]]; do
			#tantque le joueur n a pas terminer ses 10 cahnce et il n a pas encore gagne il peut donc entre une combinaison
      #on efface la combinaison entre precedement elle etait deja stoce dans le fichier played
		>./userinput
		#on demande de propose une combinaison
	      for i in `seq 1 $2`
	      do
	        echo donner $i eme couleur
	        read p
					while [[ -z "${p}" ]]; do
						echo entrer une valeur
						read p
					done
	        if grep -q $p ./$3 && !(grep -q $p ./userinput)
	         then
	           echo $p >> ./userinput
						 #si l entree n est pas valid il sera inutil de la verifier
						 averifier=true
	        else
	          echo veiullez enter une combinaison exist
						averifier=false
						#si une entre est invalid il sera inutil de continue on demande de la renter une autre fois
	          break
	        fi
	      done
				if [[ $averifier = true ]]; then
					#selement si la combinaison est valid on verifie si elle match la combinaison cherchee
					verifiercombi $1 $2 $4
				fi
				done
	  fi

}
#sauvegarde une combinaison
savegame(){
	#seule un joueur conncte peu sauvegder une combinaison
	if [[ $currentUser = false ]]; then
		clear
		echo 'vous devez etre connecte afin que vous puissez sauvegarder'
		sleep 1
		lancerMenu
	else
		#si vraiment il existe une combinaison afain de la sauvegarder
		if [[ $newgame = true && $win = false ]]; then
		   if [[ $cc -ge 10 ]]; then
			   	#si le conteur est deja > 10 on ecrie au joueur qu il ne peu pas sauvegder une combinaison que vous avez eppuise les chances de la trouver
				  >played
				  clear
				  echo vous avez deja epuiser vos chance pour cette combinaison vous ne ne pouvez plus la jouer
          sleep 1
				  #puis en revient au menu principal
		else
				  sauvegardeFile=./sauvegarde/$username
				  saveplayedFile=$sauvegardeFile'played'
				  if [[ -f $sauvegardeFile ]]; then
				  	echo l ancienne combinaison sera efface
				  	#si deja une combinaison est stock on l'ecrase
				  	#sinon on cree le fichier ou on va la stocke
				     >$sauvegardeFile
				    >$saveplayedFile
			   else
				    touch $sauvegardeFile
				    touch $saveplayedFile
				    # sauvegardeFile contiendra la combinaison et le conteur
				    #saveplayedFile contiendra les fausses combinaisons propose par le joueur
				 fi
				cp played $saveplayedFile
				cp ./input $sauvegardeFile
				clear
				  echo 'game saved you can replay the combinaison anytime you want (jous avez deja essaye ' $cc 'fois)'
				  sleep 2

			fi

		else
			clear
			echo aucune session a sauvegarder
			sleep 2
			#lancerMenu
		fi
		lancerMenu
fi
}


continugame(){
	#si le jouer n est pas connecter on peu pas recuperer sa combinaison
if [[ $currentUser = false ]]; then
		clear
		echo 'vous devez etre connecte afin que vous puissez continuer'
		sleep 1
		lancerMenu
	else
		#modifier newgame : si il decide de sauvegarder sans qu ill cree une nouvelle combi >> newgame sera modie si il cree un nouovelle combi
	newgame=false
	#le fichier ou la combinaison est stocke
  recufile=./sauvegarde/$username
	#si vraiment deja le joueur a stocke une combinaison
	if [[ -f $recufile ]]; then
		clear
		#on affiche les fausses combinaison qu il a entree la dernier fois
		afficherplateau $recufile'played'
		#a le conteur:la dernier ligne du fichier
		a=$(tail -n-1 $recufile)
	  b=$(cat $recufile | wc -l)
			#l: le niveau .. simple l = 4 ou difficile l = 5
    l=`expr $b - 1`
		#l sera passe comme parametre de la fontion sasircombi
		if [[ $l -eq 4 ]]; then
			par='easy'
		else
			par='advanced'
		fi
	  while [[ $a -le 10 ]]; do
	    Saisircombi $recufile $l $par $recufile'played'
	    a=`expr $a + 1`
	  done
	else
		clear
		echo vous "n'avez sauvegarder aucune session"
		sleep 1
		lancerMenu
	fi

	fi
}

#si le script s execute pour la premiere fois dans un repertoir on doit cree le fichier nessecaire
setup(){
	if [[ ! -d 'joueurs' ]]; then
		mkdir joueurs
	fi
	if [[ ! -d 'sauvegarde' ]]; then
		mkdir sauvegarde
	fi
	if [[ ! -d 'vainqueurs' ]]; then
		mkdir vainqueurs
	fi
	if [[ ! -f vainqueurs/winers ]]; then
		touch ./vainqueurs/winers
	fi
	if [[ ! -f index ]]; then
		touch index
	fi
	if [[ ! -f played ]]; then
		touch played
	fi
	if [[ ! -f input ]]; then
		touch input
	fi
	if [[ ! -f userinput ]]; then
		touch userinput
	fi
	if [[ ! -f advanced ]]; then
		touch advanced
		echo $'b\nm\nn\nv\nr\no\nj\ng\nc\na' >./advanced
	fi
	if [[ ! -f easy ]]; then
		touch easy
		echo $'b\nv\nr\no\nm\nj\ng\nn' >./easy
	fi
}

setup
lancerMenu
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
