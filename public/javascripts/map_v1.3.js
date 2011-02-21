/*
map.js v1.3
GoogleMapAPI v3用

2010.10.29:	住所から座標を取得できるように変更しました。
*/

/*マップ表示用*/
var mapname;	//マップID
var mc_lat = 34.6862971;	//中心座標の緯度（初期値）
var mc_lng = 135.5196609;	//中心座標の経度（初期値）
var mp_lat = 34.6862971;	//マーカーの緯度（初期値）
var mp_lng = 135.5196609;	//マーカーの経度（初期値）
var zoom = 15;		//ズーム値（初期値）
var map;
var maker;
var currentInfoWindow = null;   //最後に開いた情報ウィンドウを記憶
var locationLatLng;
	
//単一マーカー用（座標取得）
function map_single(mapname, mapcomment){

	if($("#"+mapname)[0] != null){
		
		var gmap_coords = $(".gmap_coord")[0];		//マップ座標を記述している要素
		var gmap_address = $(".gmap_address")[0];	//住所を記述している要素
		var mapdiv = $("#"+mapname)[0];		//マップを出力する要素
		
		//吹き出し用コメント
		var comment = "<div class='gmap_block'>";
		comment += $("#"+mapcomment)[0].innerHTML;
		comment += "</div>";
		
		//座標データがある場合
		if(gmap_coords != null){
			var gmap_coords_array = gmap_coords.innerHTML.split(",");
			//マーカー座標＋中心座標＋ズーム値がそろっている場合
			if(gmap_coords_array.length == 5){
				mp_lat = parseFloat(gmap_coords_array[0]);
				mp_lng = parseFloat(gmap_coords_array[1]);
				mc_lat = parseFloat(gmap_coords_array[2]);
				mc_lng = parseFloat(gmap_coords_array[3]);
				zoom = parseInt(gmap_coords_array[4]);
			//マーカー座標＋ズーム値しかない場合
			}else if(gmap_coords_array.length == 3){
				mp_lat = parseFloat(gmap_coords_array[0]);
				mp_lng = parseFloat(gmap_coords_array[1]);
				mc_lat = parseFloat(gmap_coords_array[0]);
				mc_lng = parseFloat(gmap_coords_array[1]);
				zoom = parseInt(gmap_coords_array[2]);
			//マーカー座標しかない場合
			}else if(gmap_coords_array.length == 2){
				mp_lat = parseFloat(gmap_coords_array[0]);
				mp_lng = parseFloat(gmap_coords_array[1]);
				mc_lat = parseFloat(gmap_coords_array[0]);
				mc_lng = parseFloat(gmap_coords_array[1]);
				//zoomはデフォルト値
			}else{
				alert("「gmap_coord」の中から座標を取得できませんでした。\r\n座標をご確認ください。");	
			}
			map_single_run(mapdiv, comment);
			
		//住所から座標を取得する場合
		}else if(gmap_address != null){
			var geocoder = new google.maps.Geocoder();
			var inner_gmap_address = gmap_address.innerHTML;
			
			geocoder.geocode({'address': inner_gmap_address}, 
			function(results, status) {
				//コールバック
				if (status == google.maps.GeocoderStatus.OK) {
					mp_lat = results[0].geometry.location.lat();
					mp_lng = results[0].geometry.location.lng();
					mc_lat = results[0].geometry.location.lat();
					mc_lng = results[0].geometry.location.lng();
					map_single_run(mapdiv, comment);
				}else{
					alert("住所から座標を取得できませんでした。\r\n住所をご確認ください。");	
				}
			});
		}else{
			alert("「gmap_coord」または「gmap_address」のclassが見つからないため、地図を表示できませんでした。");	
		}
	}
}

//単一マーカー用（実行処理）
function map_single_run(mapdiv, comment){
	
	// マップオプション設定
	var map_option = {
		center: new google.maps.LatLng(mc_lat, mc_lng),
		zoom: zoom,
		mapTypeId: google.maps.MapTypeId.ROADMAP   // マップタイプ
	};
		
	// マップ描画
	map = new google.maps.Map(mapdiv, map_option);
	
	// マーカー表示
	var get_obj = $(".gmap_title a")[0];
	AddGMarker(get_obj, mp_lat, mp_lng, comment);
}

//複数マーカー用
function map_all(mapname, mapcommentlist){
	
	// マップオブジェクト設定
	var mapdiv = $("#"+mapname)[0];
	var geocoder = new google.maps.Geocoder();
	
	//緯度経度の最大値、最小値の初期値
	var minLat = 999;
	var maxLat = 0;
	var minLng = 999;
	var maxLng = 0;
	
	var geocode_count = 0;
	var func_count = 0;
	
	//タグからデータを取得
	var content_list = $("#"+mapcommentlist)[0];
	var get_li_array = content_list.getElementsByTagName("li");		//項目
	var get_gmap_address_array = $(".gmap_address");
	var get_gmap_coord_array = $(".gmap_coord");
	
	// 初期設定（とりあえずマップを表示させる）
	var LatLngCenter = new google.maps.LatLng(mc_lat,mc_lng);
	
	var map_option = {
		zoom: zoom,
		center: LatLngCenter,
		scrollwheel: false,
		mapTypeId: google.maps.MapTypeId.ROADMAP   // マップタイプ
	};
	map = new google.maps.Map(mapdiv, map_option);
	
	// データが空でない場合
	if(get_li_array.length != 0){
		
		//住所から座標を取得する項目が１つも無い場合
		if(get_gmap_address_array[0] == null && get_li_array.length == get_gmap_coord_array.length){
			
			for(i=0; i<get_li_array.length; i++){
		
				//コメント
				var comment = "<div class='gmap_block'>";
				comment += get_li_array[i].innerHTML;
				comment += "</div>";
				
				//マーカー用座標
				var inner_gmap_coord = $(".gmap_coord")[i].innerHTML;
				var inner_gmap_coord_array = inner_gmap_coord.split(',');
					
				mp_lat = inner_gmap_coord_array[0];
				mp_lng = inner_gmap_coord_array[1];
				mp_lat = parseFloat(mp_lat);
				mp_lng = parseFloat(mp_lng);
				
				var get_obj = $(".gmap_title a")[i];
				
				//マーカーを表示
				AddGMarker(get_obj, mp_lat, mp_lng, comment);
				
				//中心座標を取得するため、緯度経度の最小値と最大値を取得する
				if(mp_lat < minLat){
					minLat = mp_lat;
				}
				if(mp_lat > maxLat){
					maxLat = mp_lat;
				}
				
				if(mp_lng < minLng){
					minLng = mp_lng;
				}
				if(mp_lng > maxLng){
					maxLng = mp_lng;
				}
				
				minLat = parseFloat(minLat);
				maxLat = parseFloat(maxLat);
				minLng = parseFloat(minLng);
				maxLng = parseFloat(maxLng);
				
				//中心座標とズームを自動調整
				var minLatLng = new google.maps.LatLng(minLat,minLng);
				var maxLatLng = new google.maps.LatLng(maxLat,maxLng);
				var LatLngBounds = new google.maps.LatLngBounds(minLatLng,maxLatLng);
				LatLngCenter = LatLngBounds.getCenter();
				zoom = map.fitBounds(LatLngBounds);
				
			}
		}else if(get_gmap_address_array[0] == null && get_li_array.length != get_gmap_coord_array.length){
			
			alert("「gmap_coord」クラスで囲まれた座標が存在しない項目があります。");
			
		//住所から座標を取得する項目がある場合
		}else if(get_gmap_address_array[0] != null && get_li_array.length == get_gmap_address_array.length){
		
			for(var i=0; i<get_li_array.length; i++){
				
				var normal_flag = 0;
				var nth = i+1;
				var gmap_address = $("#"+mapcommentlist+" li:nth-child("+nth+") .gmap_address")[0];
				
				var inner_gmap_address = gmap_address.innerHTML;
				geocoder.geocode({'address':inner_gmap_address}, 
				function(results, status) {
					
					func_count++;	//関数呼び出しのカウント
					
					var gmap_coord = $("#"+mapcommentlist+" li:nth-child("+func_count+") .gmap_coord")[0];
					if(gmap_coord != null){
						var inner_gmap_coord = gmap_coord.innerHTML;
					}else{
						var inner_gmap_coord = "";
					}
					
					//コメント
					var comment = "<div class='gmap_block'>";
					comment += get_li_array[geocode_count].innerHTML;
					comment += "</div>";
					
					//座標をそのまま取得できる場合
					if(inner_gmap_coord != ""){
						
						//マーカー用座標
						var inner_gmap_coord_array = inner_gmap_coord.split(',');	
						mp_lat = inner_gmap_coord_array[0];
						mp_lng = inner_gmap_coord_array[1];
						
						normal_flag = 1;
						
					//住所から座標に変換する場合
					}else if (status == google.maps.GeocoderStatus.OK) {
						
						//座標を取得
						mp_lat = results[0].geometry.location.lat();
						mp_lng = results[0].geometry.location.lng();
						
						normal_flag = 1;
					}
					
					if(normal_flag == 1){
						//座標をパースフロート
						mp_lat = parseFloat(mp_lat);
						mp_lng = parseFloat(mp_lng);
						
						//マーカー出力
						var get_obj = $(".gmap_title a")[geocode_count];
						AddGMarker(get_obj, mp_lat, mp_lng, comment);
							
						//中心座標を取得するため、緯度経度の最小値と最大値を取得する
						if(mp_lat < minLat){
							minLat = mp_lat;
						}
						if(mp_lat > maxLat){
							maxLat = mp_lat;
						}
						if(mp_lng < minLng){
							minLng = mp_lng;
						}
						if(mp_lng > maxLng){
							maxLng = mp_lng;
						}
						
						//一番最後の処理
						if(func_count == get_li_array.length){
								
							//座標をフロートパース
							minLat = parseFloat(minLat);
							maxLat = parseFloat(maxLat);
							minLng = parseFloat(minLng);
							maxLng = parseFloat(maxLng);
								
							//中心座標とズームを算出
							var minLatLng = new google.maps.LatLng(minLat,minLng);
							var maxLatLng = new google.maps.LatLng(maxLat,maxLng);
							var LatLngBounds = new google.maps.LatLngBounds(minLatLng,maxLatLng);
								
							LatLngCenter = LatLngBounds.getCenter();
							zoom = map.fitBounds(LatLngBounds);
								
						}
						geocode_count++;
					}
				});
			}
		}else if(get_gmap_address_array[0] != null && get_li_array.length != get_gmap_address_array.length){
			alert("住所から座標を取得する項目が１つでもある場合は、\r\nすべての項目の住所を「gmap_address」クラスで囲んでください。");
		}
	}
}


//マーカー表示用関数
function AddGMarker(obj, arg_mp_lat, arg_mp_lng, arg_comment){
	
	arg_mp_lat = parseFloat(arg_mp_lat);
	arg_mp_lng = parseFloat(arg_mp_lng);
	
	var position = new google.maps.LatLng(arg_mp_lat, arg_mp_lng);
	
	// マーカーオブジェクト生成
	var marker = new google.maps.Marker({
		position: position,
		map: map
	});
	
	//情報ウィンドウ描画
	var infoWindow = new google.maps.InfoWindow({
		content: arg_comment
	});
	
	//マーカーをクリックした場合
	google.maps.event.addListener(marker,"click",function(){
		if (currentInfoWindow) {
			currentInfoWindow.close();
		}
		currentInfoWindow = infoWindow;
		
		infoWindow.open(map,marker);
		
	});
	
	var browser_type = browser();
	//リストから店名をクリックした場合
	if(browser_type == "MSIE"){
		obj.attachEvent("onclick",function(){
			if (currentInfoWindow) {
				currentInfoWindow.close();
			}
			currentInfoWindow = infoWindow;
			infoWindow.open(map,marker);
		});
	}else{
		obj.addEventListener("click",function(){
			if (currentInfoWindow) {
				currentInfoWindow.close();
			}
			currentInfoWindow = infoWindow;
			infoWindow.open(map,marker);
		}, false);
	}
}

//ブラウザ判別
function browser(){
	if(navigator.userAgent.indexOf("Opera") != -1){
		type = "Opera";
	}else if(navigator.userAgent.indexOf("MSIE") != -1){
		type = "MSIE";
	}else if(navigator.userAgent.indexOf("Firefox") != -1){
		type = "Firefox";
	}else if(navigator.userAgent.indexOf("Netscape") != -1){
		type = "Netscape";
	}else if(navigator.userAgent.indexOf("Safari") != -1){
		type = "Safari";
	}else{
		type = "none"; 
	}
	return type;
}
	
