#!/bin/bash
#Made by Cloreto

sair(){

        dialog --msgbox "Programa Encerrado!" 5 25 #altura e largura
        clear
        exit

}

SEARCH=$(which smbd) #verifica se o smbd já está instalado

if [ -z $SEARCH ];then

        dialog --yesno "O samba não está instalado! Deseja instalá-lo agora?" 7 45

        if [ $? = 0 ];then

                #verificar por que não instala direto no cel
                dialog --infobox "O Servidor Samba será instalado!" 5 30
                sleep 2
                clear
                apt-get install samba; y
                dialog --msgbox 'Instalado com êxito!' 5 40
                WHI=$( which smbd ) #precisa ser uma nova variavel para verificar

                        if [ -z $WHI ];then

                                dialog --infobox 'Falha ao instalar o Samba!' 5 30
                                sleep 3
                                sair

                        else
                               dialog --msgbox 'Instalado com êxito!' 5 40
                        fi
        else
                sair
        fi

fi

########################################################################
########################### Menu do Script #############################
########################################################################

MENU=$( dialog --title 'Menu Samba'  --stdout --menu 'Escolha uma das Opções abaixo:' 0 0 0 1 'Nova Configuração' 2 'Adicionar um diretório ao compartilhamento já configurado' 3 'Adicionar um novo usuário' 4 'Sair' )

if [ -z  $MENU ];then
        sair
fi


case $MENU in #pega o resultado do menu e joga na codinção

1)
        REDE=$( dialog --stdout --inputbox 'Digite o nome da sua rede de compartilhamento:' 8  50 )
        DIR=$( dialog --stdout --inputbox 'Digite o endereço do diretório a ser compartilhado:' 8 50 )
        NAME_DIR=$( dialog --stdout --inputbox 'Qual o nome será exibido na rede para este diretório?' 8 50 )

        # Renomeando o arquivo de configuração para escrevermos um novo
        mv /etc/samba/smb.conf /etc/samba/BKsmb.conf

        # Escrevendo o novo smb.conf
        echo "[global]" > /etc/samba/smb.conf # Zerando ou criando o arquivo
        echo "workgroup = $REDE" >> /etc/samba/smb.conf
        echo "name resolve order = lmhosts wins bcast hos" >> /etc/samba/smb.conf
        echo "" >> /etc/samba/smb.conf # Escrevendo uma linha de espaço
        echo "[$NAME_DIR]" >> /etc/samba/smb.conf
        echo "path = $DIR" >> /etc/samba/smb.conf
        echo "read only = no" >> /etc/samba/smb.conf
        echo "public = yes" >> /etc/samba/smb.conf

        # Loop que adiciona usuários de outro PC
        LOOP=$( dialog --stdout --inputbox "Algum usuário de outra máquina vai usar este compartilhamento?" 10 50 )

        while [ $LOOP == "s" -o $LOOP == "sim" ];do

                USU_LA=$( dialog --stdout --inputbox "Qual o nome?" 8 25 )
                adduser $USU_LA #não funciona no termux
                smbpasswd -a $USU_LA
                LOOP=$( dialog --stdout --inputbox "Mais algum usuário para adicionar?" 8 40 )

        done

        USU=$( dialog --stdout --inputbox "Agora informe o nome do usuário para que possa ser adicionado: " 8 50 )

        smbpasswd -a $USU
        service nmbd restart > /dev/null
        service smbd restart > /dev/null
        clear

        dialog --infobox  "Configuração concluída, aguarde um momento" 5 40
        sleep 4

        ############### close 1 e tirar os redirecionamentos e ver mensagens de error, caso queira resolver  ##############
        sair;;

2)
        LOOP=$"sim"

        while [ $LOOP == "sim" -o $LOOP == 's' ];do

                DIR=$( dialog --stdout --inputbox 'Digite o endereço do novo diretório a ser compartilhado:' 8 50 )
                NAME_DIR=$( dialog --stdout --inputbox 'Qual nome será exibido na rede para este diretório?' 8 50 )
echo "" >> /etc/samba/smb.conf # Escrevendo uma linha de espaço
                echo "[$NAME_DIR]" >> /etc/samba/smb.conf
                echo "path = $DIR" >> /etc/samba/smb.conf
                echo "read only = no" >> /etc/samba/smb.conf
                echo "public = yes" >> /etc/samba/smb.conf

                LOOP=$( dialog --inputbox "Deseja adicionar mais algum diretório?" 8 40 )

        done

        service nmbd restart > /dev/null
        service smbd restart > /dev/null

        dialog --msgbox "Configuração concluída!" 5 40
        sair;;

3)
        LOOP=$"sim"

        while [ $LOOP == 'sim' -o $LOOP == 's' ];do

                USERSMB=$( dialog --stdout --inputbox 'Digite o nome de usuário:' 8 30 )

                adduser $USERSMB 2> /dev/null
                smbpasswd -a $USERSMB 2> /dev/null

                LOOP=$( dialog --stdout --inputbox 'Deseja adicionar mais algum novo usuário?' 8 40 )

        done

        service nmbd restart > /dev/null
        service smbd restart > /dev/null

        dialog --msgbox 'Configuração Concluída!' 5 40
        sair;;

4)
        sair;;
esac