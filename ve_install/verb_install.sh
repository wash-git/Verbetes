#!/bin/bash
#												SCRIPT DE INSTALAÇÃO DO MÓDULO DE VERBETES DA SUPERINTERFACE
#												OBS: as tabelas deste módulo devem começar obrigatoriamente com o prefixo ve_
#
# --------------------------------------------------------------------------------------------------------------------------+
#																															|
#                                                       CONFIGURAÇÕES INICIAIS                                              |
#                                                                                                                           |
# --------------------------------------------------------------------------------------------------------------------------+
VEROOT_UID=0							# root ID
VEPINSTVERB="ve_install"				# nome da pasta de instalação deste módulo
VEACONFVERB="verb_config.cnf"			# arquivo de configuração do módulo
# --------------------------------------------------------------------------------------------------------------------------+
#																															|
#														MENSAGENS DO SCRIPT													|
#                                                                                                                           |
# --------------------------------------------------------------------------------------------------------------------------+
#
#	Mensagens de erro
MErr01="Não é permitido executar este script como usuário root"
MErr02="Erro! Para instalar este módulo de tokens é obrigatório estar na pasta '$VEPINSTVERB'"
MErr03="Erro! Não foi encontrado o arquivo de configuração deste módulo"
MErr04="Erro! Superinterface possivelmente ainda não foi instalada. É necessário ter a Superinterface instalada para utilizar este módulo"
MErr05="Erro! Arquivo de configuração da Superinterface não encontrado"
MErr06="Interrompendo a execução do script"
MErr07="Erro! Não foi possível preparar as pastas necessárias"
MErr08="Erro! Não foi possível criar a pasta de 'logs'"
MErr09="Erro! Não foi possível se conectar com o banco de dados"
MErr10="Erro! Não foi encontrado a pasta de arquivos PHP deste módulo"
MErr11="Erro! Problemas nos procedimentos de inserção de verbetes na base de dados. Código de erro="
MErr12="Erro! Problemas nos procedimentos de criação das tabelas de verbetes. Código de erro="
MErr13="Erro! Não foi possível criar a pasta para arquivos temporários"
MErr14="Erro! Problemas na geração do arquivo de configuração do script PHP"
MErr15="Erro! Não foi possível criar a pasta 'admin'"
#
#	mensagens de informação
MInfo01="Bem vind@ ao script de instalação do Módulo de Verbetes em:   "
MInfo02="Data:"
MInfo03="Sucesso! Criada pasta de arquivos de logs"
MInfo04="Iniciando a instalação"
MInfo05="Sucesso! Conexão com o banco de dados foi realizada corretamente"
MInfo06="Parabéns!!!   A instalação do Módulo de Verbetes foi um sucesso!"
MInfo07="Aproveite e dê uma olhadinha no log da instalação que está no arquivo: "
MInfo08="Script terminado em"
MInfo09="Quantidade de tabelas geradas= "
MInfo10="Aviso: deve ser verificado as tabelas de verbetes do sistema. Este erro coloca a Superinterface com limitação de funcionamento"
MInfo11="Sucesso. Criação das tabelas de verbetes realizada corretamente"
MInfo12="Sucesso. Geração de arquivos filtrados como fontes de verbetes foi realizada corretamente (arquivos .tokens)"
MInfo13="Resumo, iniciando pelos parâmetros do ambiente:"
MInfo14="Gerar os verbetes e inseri-los na base de dados. Espere, pode demorar um pouco....." 
MInfo15="Quantidade de verbetes gerados= "
#				  códigos das mensagens
FInfor=0        # saída normal: new line ao final, sem tratamento de cor
FInfo1=1        # saída normal: new line ao final, sem tratamento de cor e sem ..... (sem pontinhos ilustrativos)
FInfo2=2        # saída sem new line ao final, sem tratamento de cor
FInfo3=3		# saída normal: new line ao final, sem tratamento de cor, espaços em branco no inicio (     )
FInfo4=4		# saída sem new line ao final, sem tratamento de cor, espaços em branco no início (     )
FSucss=5        # saída de sucesso: new line ao final da mensagem. na cor azul. No final, muda para cor branca
FSucs2=6        # saída de sucesso: new line antes e depois da mensagem, cor azul. No final, muda para cor branca
FInsuc=7        # saída de erro, na cor vermelha, com mensagem de interrupção do script
FInsu1=8        # saída de erro, na cor vermelha (apenas no screen, não enviado para arquivo de log)
FInsu2=9		# saída de erro, na cor vermelha, sem new line ao final e sem ....
FInsu3=10		# saída de erro, na cor vermelha, com new line ao final
FInsu4=11		# saída de erro, na cor vermelha, com new line ao final e com ....
#
MCor01="\e[97m"         # cor default (branca), quando for imprimir mensagens na tela
MCor02="\e[33m"         # cor amarela, quando for imprimir mensagens na tela
#
# --------------------------------------------------------------------------------------------------------------------------+
#																															|
#								FUNÇÃO AUXILIAR DE CONTROLE DE MENSAGENS AO USUÁRIO											|
#																															|
# --------------------------------------------------------------------------------------------------------------------------+
function fMens () {								# função para enviar mensagem, das seguintes formas:
	case $1 in
			$FInfor)							# com line feed ao final, cor default
				echo -e ".....$2" | tee -a "$VEPLOG"/"$VEALOG"
				;;
			$FInfo1)
				echo -e "$2" | tee -a "$VEPLOG"/"$VEALOG"
				;;
			$FInfo2)							# sem line feed, cor default
				echo -n ".....$2" | tee -a "$VEPLOG"/"$VEALOG"
				;;
			$FInfo3)
				echo -e "     $2" | tee -a "$VEPLOG"/"$VEALOG"
				;;
			$FInfo4)
                echo -n "     $2" | tee -a "$VEPLOG"/"$VEALOG"
                ;;
			$FSucs3)							# sem line feed, cor azul
				echo -ne "\e[34m.....$2\e[97m" | tee -a "$VEPLOG"/"$VEALOG"
            	;;
			$FSucss)							# com line feed ao final. cor azul
        		echo -e "\e[34m.....$2\e[97m" | tee -a "$VEPLOG"/"$VEALOG"
            	;;
			$FSucs2)							# com lines feed antes e depois, cor azul
				echo -e "\n\e[34m.....$2\e[97m" | tee -a "$VEPLOG"/"$VEALOG"
            	;;
			$FInsuc)							# com line feed depois, aviso de interrupção do script, cor vermelha
				echo -e  "\e[31m.....$2" | tee -a "$VEPLOG"/"$VEALOG"
            	echo -e ".....$MErr06\e[97m" | tee -a "$VEPLOG"/"$VEALOG"	# mens. interrompendo script
            	;;
			$FInsu1)							# na cor vermelha (apenas no screen, não enviado para arquivo de log)
				echo -e  "\n\e[31m.....$2"
				echo -e ".....$MErr06\e[97m"	# mens. interrompendo script
				;;
			$FInsu2)							# sem line feed ao final, cor vermelha
				echo -ne "\e[31m.....$2" | tee -a "$VEPLOG"/"$VEALOG"
				;;
			$FInsu3)							# com line feed ao final, cor vermelha, ao final volta cor default
				echo -e "\e[31m$2\e[97m"  | tee -a "$VEPLOG"/"$VEALOG"
				;;
			$FInsu4)							# na cor vermelha, com new line ao final e com ....
				echo -e  "\e[31m.....$2\e[97m" | tee -a "$VEPLOG"/"$VEALOG"
				;;
			*)
        		echo "\e[31m.....OOOooops!\e[97m" | tee -aa "$VEPLOG"/"$VEALOG"
            	echo $1 | tee -aa "$VEPLOG"/"$VEALOG"
            	exit
            	;;
	esac
}
#
# --------------------------------------------------------------------------------------------------------------------------+
#																															|
#											FUNÇÃO PARA VERIFICAÇÃO DO AMBIENTE												|
#																															|
# --------------------------------------------------------------------------------------------------------------------------+
function fInit () {
: '
	Consistências iniciais (principais):
	--------	--------	--------  
'
	#											verificar se é usuário root
	if [ "$EUID" -eq $VEROOT_UID ];  then 
    	fMens "$FInsu1" "$MErr01"
        exit
	fi
	#											verificar se pasta corrente é a de instalação
	if [ "${PWD##*/}" != "$VEPINSTVERB" ]; then
		fMens "$FInsu1" "$MErr02"
        exit
    fi
	#											verificar se arquivo de configuração deste módulo está disponível
	if [ ! -f $VEACONFVERB ]; then
		fMens "$FInsu1" "$MErr03"
		exit
	fi
	#
	source  $VEACONFVERB						# inserir arquivo de configuração deste módulo
	#
	#											verificar se a Superinterface está instalada
	if [ ! -d $VEPINSTSUPER ]; then
    	fMens "$FInsu1" "$MErr04"
        exit
	fi
	#											verificar se arquivo de configuração da Superinterface está disponível
    if [ ! -f $VEPINSTSUPER/$VEACONFSUPER ]; then
    	fMens "$FInsu1" "$MErr05"
    	exit
    fi
	source  $VEPINSTSUPER/$VEACONFSUPER			# inserir arquivo de configuração da Superinterface
	#											definir permissões iniciais temporárias de acesso a pastas e arquivos
	find ../ve_* -type d -exec chmod $VECHMOD750 {} \;
	find ../ve_* -type f -exec chmod $VECHMOD640 {} \;
	chmod $VECHMOD500 ./*.sh
	#											limpar pastas
	rm -rf {$VEPLOG,$VEPADMIN,$VEPTEMP}  2>/dev/null
	if [ $? -ne 0 ]; then
		fMens "$FInsu1" "$MErr07"
		exit
	fi
	mkdir $VEPLOG								# criar pasta para arquivo de logs do módulo 
	if [ $? -ne 0 ]; then
		fMens "$FInsu1" "$MErr08"
		exit
	fi
	mkdir $VEPTEMP								# criar pasta para arquivos temporários do módulo
	if [ $? -ne 0 ]; then
		fMens "$FInsu1" "$MErr13"
		exit
	fi
	mkdir $VEPADMIN								# criar pasta de admin do módulo (utilizado pelo script PHP)
	if [ $? -ne 0 ]; then
		fMens "$FInsu1" "$MErr15"
		exit
	fi
	#
	fMens "$FInfo1" "$MCor02"					# saída na cor amarela
	fMens "$FInfo2" "$MInfo01"					# enviar mensagem de boas vindas
	fMens "$FInfo1" "$0"						# $0
	fMens "$FInfor" "$MInfo02:  $(date '+%d-%m-%Y as  %H:%M:%S') --- $MInfo04"
	fMens "$FInfo1" "$MCor01"
	fMens "$FSucss" "$MInfo03"					# sucesso na criação de pasta de logs
	#											verificar existência de pasta de arquivos de PHP's deste módulo
#	if [ ! -d $VEPPHP ]; then
#		fMens "$FInsuc" "$MErr10"
#		exit
#	fi
	#											verificar a conexão com o banco de dados
    mysql -u $CPBASEUSER -b $CPBASE -p$CPBASEPASSW -e "quit" 2>/dev/null
	if [ $? -ne 0 ]; then
    	fMens "$FInsuc" "$MErr09"
		exit
    else
			fMens "$FSucss" "$MInfo05"
	fi
}

#
# --------------------------------------------------------------------------------------------------------------------------+
#											 											                                    |
#			   				   	                FUNÇÃO PARA INFORMAR UM RESUMO DA BASE DE DADOS							    |
#																						                                    |
# --------------------------------------------------------------------------------------------------------------------------+
fResumo () {
	#								resumo de informações da instalação realizada
	fMens "$FInfor" "$MInfo13"
	fMens "$FInfo3" "$($SHELL --version | head -1)"
	fMens "$FInfo3" "$(/usr/bin/lsb_release -ds)"
	fMens "$FInfo3" "$(printenv LANG)"
	fMens "$FInfo3" "$(php -v | head -1)"
	fMens "$FInfo3" "$(mysql  -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e \"select @@version\" | head -1)"
	fMens "$FInfo3" "$(/usr/bin/id -un)"
	fMens "$FInfo2" "$MInfo09"
	TABLES=$(mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e 'show tables' | awk '{ print $1}' | grep -v '^Tables' | grep ve_*);
        aa=( $TABLES )
        fMens   "$FInfo1"       "${#aa[@]}"
	fMens "$FInfo2" "$MInfo15"
	fMens "$FInfo1" "$(mysql -N -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e "SELECT count(*) FROM ve_acervoverb")"
}
#
#
# --------------------------------------------------------------------------------------------------------------------------+
#											 																				|
#			   				   	                FUNÇÃO CRIAR TABELAS RESERVADAS	DE TOKENS									|
#																															|
# --------------------------------------------------------------------------------------------------------------------------+
fCriarTabsVerbetes () {

fExitOnError () {
	sql="DELETE FROM $VETABDOCVERB"
	mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql"
	sql="DELETE FROM $VETABACERVOVERB"
	mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql"
	resultado="false"
	cod_error=$1
}
#
cod_error=0
resultado=""							# esta variável vazia indica inexistência de erro.
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e "drop table IF EXISTS $VETABDOCVERB;drop table IF EXISTS $VETABACERVOVERB" || fExitOnError "1"
test $resultado && return $cod_error

sql="CREATE TABLE $VETABACERVOVERB (id_chave_verb int not null auto_increment, nome_verb varbinary(100), funcao varchar(100), ocorrencias int, primary key(id_chave_verb),unique(nome_verb))"
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql" || fExitOnError "2"
test $resultado && return $cod_error

sql="ALTER TABLE $VETABACERVOVERB comment='Lista de (quase) todas as palavras que estão presentes nos arquivos do acervo, exceto números e outros caracteres especiais. Contém também a quantidade de ocorrências de cada palavra no acervo.'"
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql" || fExitOnError "3"
test $resultado && return $cod_error

sql="CREATE TABLE $VETABDOCVERB (id_chave_docsverb int not null auto_increment, id_documento int, id_verbete int, linha_ocorrencia int, primary key(id_chave_docsverb))"
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql"  || fExitOnError "4"
test $resultado && return $cod_error

sql="ALTER TABLE $VETABDOCVERB ADD CONSTRAINT FK_verb_acervo FOREIGN KEY (id_verbete) REFERENCES $VETABACERVOVERB(id_chave_verb)"
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql" || fExitOnError "5"
test $resultado && return $cod_error

sql="ALTER TABLE $VETABDOCVERB ADD CONSTRAINT FK_verb_documents FOREIGN KEY (id_documento) REFERENCES su_documents(id_chave_documento)"
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql" || fExitOnError "6"
test $resultado && return $cod_error

sql="ALTER TABLE $VETABDOCVERB comment='Tabela de ligação entre cada palavra presente nos arquivos do acervo e os documentos.'"
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE -e " $sql" || fExitOnError "7"
test $resultado && return $cod_error

return 0
}
#
#
# --------------------------------------------------------------------------------------------------------------------------+
#											 																				|
#			   				   	                FUNÇÃO PARA GERAR ARQUIVOS													|
#																															|
# --------------------------------------------------------------------------------------------------------------------------+
fGerarArquivos () {
#
#												Gerar tokens: palavras que aparecem nos conteúdos dos arquivos
	substituir1=( 								# bloco1: caracteres únicos
	"º" #    1
	"°" #    2
	"\"" #   3
	"“" #    4
	"”" #    5
	"±" #    6
	"ª" #    7
	"●" #    8
	"" #    9
	"•" #    10
	"→" #    11
	"−" #    12
	"–" #    13
	"‘’" #   14
	)
	#
	substituir2=( 								# bloco2: caracteres rodeados por espaços
	" a "
	" e "
	" i "
	" o "
	" u "
	" é "
	" al " #  1
	" as " #  2
	" às " #  3
	" ao " #  4
	" aos " # 5
	" cm " #  6
	" com " # 7
	" da " #  8
	" das " # 9
	" de " # 10
	" do " # 11
	" dos " #12
	" et " # 13
	" em " # 14
	" no " # 15
	" na " # 16
	" nas " #17
	" um " # 18
	" www " #19
	" ou " # 20
	" os " # 21
	" on " # 22
	" se " # 23
	)
	#
	for ((j=0; j<${#substituir1[@]}; j++));do	# gerar array com caracteres que serão inseridos: no caso, a substituição será por um espaço
		substituto1[$j]=" "						# bloco-1 de caracteres
	done
	#
	for ((j=0; j<${#substituir2[@]}; j++));do	# gerar array com caracteres que serão inseridos: no caso, a substituição será por um espaço
		substituto2[$j]=" "						# bloco-2 de caracteres
	done
	for i in  "$CPPIMAGEM"/*.txt
	do
		#										Lista de filtragens (nesta ordem):
		#										1) retirar caracteres/palavras que constam na lista do array "substituir" - bloco 1
		#										2) mascara provisoriamente fim de linha (já que irá ser retirado caracteres de controle)
		#										3) deixa todo conteúdo do arquivo em minuscula
		#										4) deixa caracteres acentuados e cedilha em minusculo
		#										5) retirar caracteres de controle, digitos e pontuação (.,?: ...)
		#										6) volta a colocar marcação original de fim de linha
		#										7) retira ctrl-L
		#										8) insere um espaço no início de cada linha (para capturar possíveis caracteres isolados)
		#										9) insere um espaço no final de cada linha  (para capturar possíveis caracteres isolados)
		#										10) retirar caracteres isolados
		#										11) retirar caracteres/palavras que constam na lista do array "substituir" - bloco 2
		cp -f $i $i".token"
		for ((j=0; j<${#substituir1[@]}; j++));do	# substituições relativas ao bloco-1
			mv -f $i".token" "$CPPWORK"/su_arq_temporariotoken.txt
			sed -e "s/${substituir1[$j]}/${substituto1[$j]}/g" < "$CPPWORK"/su_arq_temporariotoken.txt > $i".token"
			if [ $? -ne 0 ]; then
				mv -f $CPPWORK/*.[pP][dD][fF] $CPPQUARENTINE/. 2>/dev/null	# enviar os arquivos PDF para quarentena
				rm -f $CPPWORK/*.*
				fMens "$FInsu4" "$MErr51"
				fMens "$FInfor" "$MInfo38"
				return
			fi
		done
		#
		mv -f $i".token" "$CPPWORK"/su_arq_temporariotoken.txt
		tr '\r\n' '\275\276' < "$CPPWORK"/su_arq_temporariotoken.txt | tr [:upper:] [:lower:] | sed  'y/ÁÀÃÉÊÍÓÕÇ/áàãéêíóõç/' | tr [:cntrl:][:digit:][:punct:] ' ' | tr "\275\276" "\r\n" | sed 's/^L/ /g' | sed 's/^/ /g' | sed 's/$/ /g'  | sed -e "s/[[:space:]][a-zA-Z][[:space:]]/ /g"  > $i".token"
		if [ $? -ne 0 ]; then
			mv -f $CPPWORK/*.[pP][dD][fF] $CPPQUARENTINE/. 2>/dev/null	# enviar os arquivos PDF para quarentena
			rm -f $CPPWORK/*.*
			fMens "$FInsu4" "$MErr51"
			fMens "$FInfor" "$MInfo38"
			return
		fi
		#
		for ((j=0; j<${#substituir2[@]}; j++));do	# substituições relativas ao bloco-2
			mv -f $i".token" "$CPPWORK"/su_arq_temporariotoken.txt
			if [ $? -ne 0 ]; then
				mv -f $CPPWORK/*.[pP][dD][fF] $CPPQUARENTINE/. 2>/dev/null	# enviar os arquivos PDF para quarentena
				rm -f $CPPWORK/*.*
				fMens "$FInsu4" "$MErr52"
				fMens "$FInfor" "$MInfo38"
				return
			fi
			sed -e "s/${substituir2[$j]}/${substituto2[$j]}/g" < "$CPPWORK"/su_arq_temporariotoken.txt > $i".token"
			if [ $? -ne 0 ]; then
				mv -f $CPPWORK/*.[pP][dD][fF] $CPPQUARENTINE/. 2>/dev/null	# enviar os arquivos PDF para quarentena
				rm -f $CPPWORK/*.*
				fMens "$FInsu4" "$MErr52"
				fMens "$FInfor" "$MInfo38"
				return
			fi
		done
	done
	rm -f $CPPWORK/su_arq_temporariotoken.txt
	fMens "$FSucss" "$MInfo12"						# sucesso na geração de tokens

}
#
#
# --------------------------------------------------------------------------------------------------------------------------+
#											 																				|
#			   				   	                FUNÇÃO PARA GERAR VERBETES													|
#																															|
# --------------------------------------------------------------------------------------------------------------------------+
fGerarVerbetes () {
fTratarErro() {
	cod_err=$1
	fCriarTabsTokens
	fMens	"$FInsu4"	"$MErr11$cod_err"
	fMens	"$FInfor"	"$MInfo10"
	resultado="false"						# saída de erro
}
fMens "$FInfor" "$MInfo14"
resultado=""							# esta variável vazia indica inexistência de erro.
										# abaixo: gera um arquivo com a listagem dos verbetes e a quantidade de vezes que cada verbete foi encontrado
cat $CPPIMAGEM/*.token | tr [:punct:] ' ' | tr '\n' ' ' | sed 's/  / /g' | sed 's/\f//g' | sed 's/ /\n/g' | sed '/^[[:space:]]*$/d' | sed 's/\s//g' | sort | uniq -c > $VEPTEMP/verbetes_unicos_com_contagem.csv || fTratarErro "1"
test $resultado && return

										# abaixo: um filtro adicional para eliminar possíveis letras isoladas
cat $VEPTEMP/verbetes_unicos_com_contagem.csv |sed '/\ [a-z]$/d' > $VEPTEMP/verbetes_unicos_com_contagem_filtrados.csv  || fTratarErro "2"
test $resultado && return

										# abaixo: gera arquivo de INSERTs dos verbetes, acompanhado da quantidade de vezes que ele foi encontrado nos arquivos
cat $VEPTEMP/verbetes_unicos_com_contagem_filtrados.csv | awk '{print "insert into ve_acervoverb (nome_verb, ocorrencias) values (\""$2"\",\""$1"\");";}' > $VEPTEMP/verbetes_inserts_verb.sql  || fTratarErro "3"
test $resultado && return

										# abaixo: alimenta a tabela ve_acervoverb da base de dados
mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE < "$VEPTEMP/verbetes_inserts_verb.sql"  || fTratarErro "4"
test $resultado && return

										# abaixo: gera arquivo com comandos de criação dos arquivos com extensão .txt.token.com_new_line 
ls -1 $CPPIMAGEM/*.token |  awk '{print "cat "$1" | tr [:punct:] \" \" |  tr \"\\n\" \" \" | sed \"s/  / /g\" | sed \"s/^L/ /g\" | sed \"s/\\f//g\" | sed \"s/ /\\n/g\" | sed \"/^[[:space:]]*$/d\" > "$1".com_new_line";}' > $VEPTEMP/verbetes_arquivos_com_new_line.bash  || fTratarErro "5"
test $resultado && return

chmod +x $VEPTEMP/verbetes_arquivos_com_new_line.bash
./$VEPTEMP/verbetes_arquivos_com_new_line.bash  || fTratarErro "6"
test $resultado && return

										# abaixo: gera arquivo com comandos grep -Hoxn 
										#(imprime o nome do arquivo para cada "match" encontrado, número da linha, o verbete). 
cat $VEPTEMP/verbetes_unicos_com_contagem_filtrados.csv | awk '{print "grep -Hoxn \""$2"\" ../su_imagens/*.txt.token.com_new_line"}' > $VEPTEMP/verbetes_ocorrencias.bash  || fTratarErro "7"
test $resultado && return

										# abaixo: cria arquivo com a relação verbete x arquivo x linha da ocorrência
chmod +x $VEPTEMP/verbetes_ocorrencias.bash
./$VEPTEMP/verbetes_ocorrencias.bash > $VEPTEMP/verbete_ocorrencias_com_dash.csv  || fTratarErro "8"
test $resultado && return

										# abaixo: cria arquivo de INSERTs relacionando arquivo x linha da ocorrência x verbete
cat $VEPTEMP/verbete_ocorrencias_com_dash.csv | awk 'BEGIN{FS=":"}{gsub(/\.txt.token\.com_new_line/,".pdf",$1);print "insert into ve_documentsverb (id_documento, linha_ocorrencia, id_verbete) values ((select id_chave_documento from su_documents where photo_filename_documento=\""$1"\"),"$2",(select id_chave_verb from ve_acervoverb where nome_verb=\""$3"\"));"}' > $VEPTEMP/verbetes_inserts_ocorrencias.sql  || fTratarErro "9"
test $resultado && return

mysql -u $CPBASEUSER -p$CPBASEPASSW -b $CPBASE < "$VEPTEMP/verbetes_inserts_ocorrencias.sql"  || fTratarErro "10"
rm $VEPTEMP/*.*
}
#
# --------------------------------------------------------------------------------------------------------------------------+
#                                                                                                                           |
#                                       FUNÇÃO PARA CONFIGURAR AUTORIDADES DE PASTAS E ARQUIVOS                             |
#                                                                                                                           |
# --------------------------------------------------------------------------------------------------------------------------+
vefSeguranca () {
	#										definir permissões de acesso para pastas e arquivos
	find ../ve_* -type d -exec chmod $VECHMOD750 {} \;
	find ../ve_* -type f -exec chmod $VECHMOD640 {} \;
	chmod $VECHMOD400 $VEACONFVERB			# definir permissão para o arquivo de configuração do módulo
	chmod $VECHMOD400 $VEPADMIN/$VEACONFPHP	# definir permissão para o arquivo de configuração utilizado pelos scripts PHP
	chmod $VECHMOD500 ./*.sh				# definir permissão para arquivos de scripts shell da pasta de instalação
}
#
# --------------------------------------------------------------------------------------------------------------------------+
#																															|
#							              FUNÇÃO PARA CRIAR ARQUIVO DE CONFIGURAÇÃO PARA O SCRIPT PHP                       |
#																															|
# --------------------------------------------------------------------------------------------------------------------------+
#
vefCriaConfPhp () {
	echo -e "<?php\n\$banco = \"$CPBASE\";\n\$username = \"$CPBASEUSER\";" > $VEPADMIN/$VEACONFPHP
	echo -e "\$pass = \"$CPBASEPASSW\";"        >> $VEPADMIN/$VEACONFPHP
	echo -e "\$pastalogs = \"$VEPLOG\";"        >> $VEPADMIN/$VEACONFPHP
	echo -e "\$pastaadmin = \"$VEPADMIN\";"     >> $VEPADMIN/$VEACONFPHP
	echo -e "\$arqlogs   = \"$VEALOG\";"        >> $VEPADMIN/$VEACONFPHP
	echo -e "?>\n" >> $VEPADMIN/$VEACONFPHP
	#                                           verificar criação do arquivo de configuração para o PHP
	if [ $? -ne 0 ]; then
		fMens "$FInsuc" "$MErr14"
		exit
	fi

}

# --------------------------------------------------------------------------------------------------------------------------+
#																															|
#							              CONTROLE E CORPO PRINCIPAL DO SCRIPT												|
#																															|
# --------------------------------------------------------------------------------------------------------------------------+
#
#
fInit							# testes do ambiente e preparações iniciais
#
fCriarTabsVerbetes							# criar as tabelas de verbetes
codretorno=$?
if [ $codretorno -eq 0 ]; then
	fMens	"$FSucss"	"$MInfo11"
else
	fMens	"$FInsu4"	"$MErr12$codretorno"
	fMens	"$FInfor"	"$MInfo10"
	exit
fi
fGerarArquivos
fGerarVerbetes
#												resumo
vefCriaConfPhp
vefSeguranca								# definir autoridade de acesso a pastas e arquivos
fResumo
#								mensagem de fim do script com sucesso
fMens	"$FSucss"	"$MInfo06"
fMens	"$FInfor"	"$MInfo08:  $(date '+%d-%m-%Y as  %H:%M:%S')"
exit	0

