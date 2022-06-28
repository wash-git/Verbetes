<?php
/*
* +--------------------------------------------------------------------+
* | Programa Wash - Módulo de Verbetes       version 2.0               |
* +--------------------------------------------------------------------+
* | Copyright Observatorio LLC (c) 2022    Antonio Albuquerque         |
* +--------------------------------------------------------------------+
* | This file is a part of Wash Project development.                   |
* | Wash program:  http://wash.net.br
* |                                                                    |
* | This PHP code is free software: you can copy, modify,              |
* | redistribute it under the terms of the GNU General Public          |
* | License (GNU-GPL) as published by the Free Software Foundation,    |
* | either version 3 of the License, or (at your option) any later     |
* | version.                                                           |
* |                                                                    |
* | This program is distributed in the hope that it will be useful,    |
* | but WITHOUT ANY WARRANTY; without even the implied warranty of     |
* | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      |
* | GNU Lesser General Public License for more details.                |
* |                                                                    |
* | A copy of the GNU Lesser General Public License is available at    |
* | <http://www.gnu.org/licenses/lgpl-3.0.html>.                       |
* +--------------------------------------------------------------------+
*/
#
/*
+-----------------------------------------------------------------------------------+
Esse provedor de dados envia a resposta através de um Json com a seguinte estrutura:
{"result":"FAlSE/TRUE","values":_____}

Onde:
	"result":
		FALSE: se houve um problema para encontrar os dados solicitados.
		TRUE: encontrou os dados solicitados, que estarão lsitados em "values".
	"values":
		se "result"=FALSE, conterá um código de erro.
		se "result"=TRUE, conterá os dados solicitados.

	Códifos de erro (quando "result"=FALSE):
		0 = não foi possível se conectar com a base de dados.
		1 = não foram encontrados dados
+-----------------------------------------------------------------------------------+
*/
#
require_once("../ve_admin/verb_config_php.cnf");
//	por segurança, evitar cacheamento: não armazenar a página em cache
$gmtDate = gmdate("D, d M Y H:i:s");
header("Expires: {gmtDate} GMT");
header("Last-Modified: {gmtDate} GMT");
header("Cache-Control: no-cache, must-revalidate");
header("Pragma: no-cache");
//
$acao=$_POST["acao"];
switch ($acao) {
	case 'listarVerbetes':
		pedidoListarVerbetes();
		break;
	default:
		break;
}
//
function	pedidoListarVerbetes() {
	global $username,$pass,$banco;
	// 										solicitado informar quais verbetes existem na base
	$link = mysqli_connect("localhost",$username, $pass, $banco);
	if ( mysqli_connect_errno()) {
  		$result='FALSE';
  		$values=0;
	}else {
		$sql = "SELECT nome_verb,ocorrencias FROM  ve_acervoverb";
		$result=mysqli_query($link, $sql);
		mysqli_close($link);
		if ( ! mysqli_num_rows($result) > 0) {
			// 								não encontrou resultados
			$result='FALSE';
			$values=1;
		}else {
			while ($row = mysqli_fetch_assoc($result)) {
    			$values[] = $row;
    		}
			$result='TRUE';
		}
	}
	#										enviar a resposta
	header("Content-Type: application/json", true);
	echo  json_encode(array('resultado' => $result, 'values' => $values));

}
?>

