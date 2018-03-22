<?php 
$mysqli = new mysqli("localhost", "zabbix", "", "");

#$query = "SELECT g.groupid AS group_id,g.name AS group_name,hi.host AS inventory_name,ie.ip FROM groups AS g LEFT JOIN hosts_groups AS hg ON hg.groupid=g.groupid LEFT JOIN hosts AS hi ON hi.hostid=hg.hostid LEFT JOIN interface AS ie ON ie.hostid=hg.hostid WHERE g.name LIKE 'gr_%' ORDER BY g.name";
$query = "SELECT g.groupid AS group_id,g.name AS group_name,hi.host AS inventory_name,ie.ip,hi.status AS status FROM groups AS g LEFT JOIN hosts_groups AS hg ON hg.groupid=g.groupid LEFT JOIN hosts AS hi ON hi.hostid=hg.hostid LEFT JOIN interface AS ie ON ie.hostid=hg.hostid WHERE (g.name LIKE 'gr_%') and (g.name NOT LIKE 'gr_hostservers%') and (hi.status=0) ORDER BY g.name";
#print($query);
if($result = $mysqli->query($query)) { 
    $data_obj = array();
#    print_r($result);
    /* выборка данных и помещение их в объекты */
    while ($obj = $result->fetch_object()) {
        $data_obj['groups'][$obj->group_id] = array(
 		'group_name'=>$obj->group_name
        );
        $data_obj['items'][$obj->group_id][] = array(
		'inventory_name'=>$obj->inventory_name,	
        	'ip'=>$obj->ip
        );
    }

header("Content-type: text/plain");
foreach($data_obj['groups'] as $group_id=>$group){
       echo '['.$group['group_name']."]\n";
	foreach($data_obj['items'][$group_id] as $item){
		echo '#'.$item['inventory_name']."\n";
		echo $item['ip'].' ansible_ssh_host='.$item['ip']."\n";
	}
	echo "\n";
}



    /* очищаем результирующий набор */
    $result->close();
}
?>

