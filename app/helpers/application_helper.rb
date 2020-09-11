#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2013 Santiago Ramos <sramos@sitiodistinto.net>
#
#    Este programa es software libre: usted puede redistribuirlo y/o modificarlo
#    bajo los términos de la Licencia Pública General GNU publicada
#    por la Fundación para el Software Libre, ya sea la versión 3
#    de la Licencia, o (a su elección) cualquier versión posterior.
#
#    Este programa se distribuye con la esperanza de que sea útil, pero
#    SIN GARANTÍA ALGUNA; ni siquiera la garantía implícita
#    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO.
#    Consulte los detalles de la Licencia Pública General GNU para obtener
#    una información más detallada.
#
#    Debería haber recibido una copia de la Licencia Pública General GNU
#    junto a este programa.
#    En caso contrario, consulte <http://www.gnu.org/licenses/>.
#################################################################################
#
#++



# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #--
  # METODOS GENERALES
  #++

  # Obtiene el valor de un campo
  def obtiene_valor_campo valor, campo
    campo.split('.').each do |metodo|
      valor = (metodo =~ /(\S+)\s(\S+)/ ? valor.send($1,$2) : valor.send(metodo)) if valor
    end
    return valor
  end

  def cabecera_listado tipo, otros={}
    # Sacamos los campos a mostrar bien vengan como array (posicion global) o como tipo
    @campos_listado = tipo.is_a?(Array) ? tipo : campos_listado(tipo)
    # Dibujamos la cabecera del listado
    cadena = "<div class='listado'><div class='listadocabecera'>"
    for campo in @campos_listado
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='listado_campo_etiqueta_" + campo + "'>" + etiqueta(campo)[0] + "</div>"
    end
    cadena += "<div class='listado_derecha'>"
    cadena += link_to( icono( "Download", {:title => "Exportar a XLS"}), request.parameters.merge({:format => :xls, :format_xls_count => (@formato_xls.to_i+1)}) ) if @formato_xls
    cadena += modal icono('Plus',{:title => "Nuevo"}), otros[:url], otros[:title] || "Nuevo" if otros[:url]
    cadena += "</div></div>"
    return cadena.html_safe
  end

  def fila_listado objeto, id=nil
    cadena = ""
    i=0
    for campo in @campos_listado
      if objeto.class.name == "Array"
        valor=objeto[i] || ""
      else
        #valor=objeto
        #campo.split('.').each { |metodo| valor = valor.send(metodo) if valor } if objeto
        valor = obtiene_valor_campo objeto, campo
      end
      i += 1
      etiqueta=etiqueta(campo)
      valor = valor.localtime.strftime("%d/%m/%Y %H:%M:%S") if valor.class.name == "ActiveSupport::TimeWithZone"
      valor = "Sí" if valor.class.name == "TrueClass"
      valor = "No" if valor.class.name == "FalseClass" && campo != "valor_defecto"
      valor = valor.strftime("%d/%m/%Y") if valor.class.name == "Date"
      cadena += "<div class='listado_campo_" + etiqueta[1] + (etiqueta[3]||"") + "' id='listado_campo_valor_" + campo + (objeto.class.name == "Array" ? "" : "_" + objeto.id.to_s) + "' title='" + (valor ? valor.to_s : "&nbsp;") + "'>" + (valor && valor.to_s != "" ? truncate( (etiqueta[3]=="f"?sprintf("%.2f",valor):valor.to_s), :length => etiqueta[2]):"&nbsp;") + '</div>'
    end
    #cadena += "</div>"
    return cadena.html_safe
  end

  def final_listado *objeto
    cadena = ""
    #cadena << "<div class='linea' id='paginado'><br/></div><div class='elemento_derecha'>" + (will_paginate(objeto) || "") + "</div>" if !objeto.nil?
    cadena += paginacion( objeto[0], session[:por_pagina] ) if objeto[0]
    cadena += "</div>"
    return cadena.html_safe
  end

  # paginación, se integra en final_listado
  def paginacion elementopaginado, elementosxpagina
    formulario  = "<div class='listadofila' id='paginado'>" + (will_paginate(elementopaginado, class: "listado_campo_2") || " ")
    formulario += "<div class='listado_derecha'> "+ informacion_paginacion(elementopaginado)  + "</div>"
    formulario += "<div class='linea'></div></div>"
    return formulario.html_safe
  end

  # completa paginacion
  def informacion_paginacion collection
      if collection.total_pages < 2
        case collection.size
        when 0; "<b>" + "No tiene elementos" + "</b>"
        when 1; "<b>" + "Mostrando 1 elemento" + "</b>"
        else;   "<b>" + "Mostrando todos los elementos: " + (collection.size).to_s + "</b>"
        end
      else
        "Mostrando elementos" + " <b>"+ (collection.offset + 1).to_s + " - " + (collection.offset + collection.length).to_s + "</b> de <b> " + (collection.total_entries).to_s +
            "</b>" + " en total"
      end
  end

  def cabecera_sublistado rotulo, tipo, sub_id, nuevo={}, clase="sublistado"
    #@campos_sublistado = campos
    @campos_sublistado = tipo.is_a?(Array) ? tipo : campos_listado(tipo)
    script = "document.getElementById('" +  sub_id + "').innerHTML=\"\";" if sub_id
    cadena = '<br><fieldset class="' + clase + '"> <legend>'+ rotulo +'</legend>'
    cadena += '<div class="listado_derecha" id="cerrarsublistado">'
    cadena += link_to( icono( "Download", {:title => "Exportar a XLS"}), request.parameters.merge({:format => :xls}) ) if @formato_xls
    cadena += link_to_function( icono('Cancel',{:Title => "Ocultar"}), script, {:id => sub_id + "_ocultar_sublistado"} ) if sub_id
    cadena += "</div><br/><br/><div class='listadocabecera'>"
    for campo in @campos_sublistado
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='sublistado_campo_valor_" + campo + "' >" + etiqueta(campo)[0] + "</div>"
    end
    if nuevo[:url] && nuevo[:title]
      cadena += '<div class="listado_derecha">'
      cadena += modal(icono('Plus',{:title => nuevo[:title]}), nuevo[:url], nuevo[:title])
      cadena += '</div>'
    end
    cadena += '</div>'
    return cadena.html_safe
  end

  def fila_sublistado objeto
    cadena = ""
    for campo in @campos_sublistado
      #valor=objeto
      #campo.split('.').each { |metodo| valor = valor.send(metodo) if valor }
      valor = obtiene_valor_campo objeto, campo
      valor = format('%0.2f',valor) if etiqueta(campo)[3] == "f" && valor
      valor = valor.strftime("%d/%m/%Y") if valor.class.name == "Date"
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='listado_campo_valor_" + campo + "' title='" + (valor ? valor.to_s : "&nbsp;") + "'>" + (valor && valor.to_s != "" ? truncate(valor.to_s, :length => etiqueta(campo)[2]):"&nbsp;") + '</div>'
    end
    return cadena.html_safe
  end

  # Dibuja los elementos del final del sublistado.
  def final_sublistado
      return "</fieldset>".html_safe
  end

  def icono tipo, propiedades={}
    size = propiedades[:size] == 'grande'? 32 : 16
    image_tag("/images/iconos/" + size.to_s + "/" + tipo + ".png", :border => 0, :class => (propiedades[:size] == "grande" ? "" : "icono"), :title => propiedades[:title] || "", :style => propiedades[:style] || '', :alt => propiedades[:title], :onmouseover => "this.src='/images/iconos/" + size.to_s + "/" + tipo + ".png';", :onmouseout => "this.src='/images/iconos/" + size.to_s + "/" + tipo + ".png';" )
  end

  def inicio_formulario url, ajax, otros={}
    if ajax
      cadena = form_remote_tag( :url => url, :html => {:id => otros[:id]||"formulario_ajax", :class => "formulario"}, :multipart => true, :loading => "Element.show('spinner'); Element.hide('botonguardar');", :complete => "Element.hide('spinner')")
      cadena += "<div class='fila' id='spinner' style='display:none'></div>".html_safe
    else
      cadena = form_tag( url, :multipart => true, :id => otros[:id]||"formulario", :class => "formulario" )
    end
    cadena += "<div class='fila'></div>".html_safe
    return cadena.html_safe
  end

  def texto rotulo, objeto, atributo, valor=nil, otros={}
    cadena = ("<div class='elemento'>" + rotulo +"<br/>").html_safe
    opciones = {:class => "texto", :id => "formulario_campo_" + objeto + "_" + atributo, :type => "d" }
    opciones[:value] = valor if valor
    if otros[:autocomplete]
      cadena << text_field_with_auto_complete( objeto, atributo, {:class => "texto"}, {:method => :get, :with => "'search=' + element.value"} )
    else
      cadena << text_field( objeto, atributo, opciones)
    end
    return cadena + "</div>".html_safe
  end

  def fecha rotulo, objeto, atributo, valor=nil, discards=[false, false]
    cadena = ("<div class='elemento_x1'>" + rotulo + "<br/>").html_safe
    #cadena << date_select(objeto, atributo, {:discard_day=>discards[0], :discard_month=>discards[1], :order => [:day,:month,:year], :class => "texto", :id => "formulario_campo_" + objeto + "_" + atributo, :default => valor})
    otros = {}
    year_range = [2010, Time.now.year + 5]
    otros[:min] = Date.new(year_range[0])
    otros[:max] = Date.new(year_range[1])
    otros[:size] = "10"
    #otros[:value] = I18n.l(valor) if valor
    #cadena << calendar_date_select(objeto, atributo, otros)
    #puts "---> valor: " + valor.inspect
    cadena += date_field(objeto, atributo, otros)
    cadena += "</div>".html_safe
    return cadena
  end

  def fecha_mes rotulo, objeto, atributo, valor=nil
    fecha rotulo, objeto, atributo, valor, [true,false]
  end

  def fecha_anno rotulo, objeto, atributo, valor=nil
    fecha rotulo, objeto, atributo, valor, [true,true]
  end

  #def selector rotulo, objeto, atributo, valores, valor=nil, tipo=nil, vacio=false
  def selector rotulo, objeto, atributo, valores, opciones={}
    cadena = ("<div class='elemento_" + (opciones[:tipo] || "x15") + "' id='selector_" + objeto + "_" + atributo + "'>" + rotulo + "<br/>").html_safe
    clase = opciones[:enriquecido] ? "chosen_select " : ""
    clase += (opciones[:tipo] || 'x15')
    if opciones[:valor].blank?
      cadena << select(objeto, atributo, valores, {:id => "formulario_campo_" + objeto + "_" + atributo, :include_blank => opciones[:vacio]}, {:class => clase})
    else
      cadena << select(objeto, atributo, valores, {:id => "formulario_campo_" + objeto + "_" + atributo, :selected => opciones[:valor], :include_blank => opciones[:vacio]}, {:class => clase})
    end
    cadena += "</div>".html_safe
    return cadena
  end

  # check_box
  def checkbox rotulo, objeto, atributo, otros={}
    clase = otros[:clase]||''
    title = otros[:title] ? ("title = '" + otros[:title] + "'" ) : ""
    if otros[:izquierda]
      ('<div class="elemento' + clase + '" #{title}>' + ( ("<br>" if otros[:abajo]) || "")).html_safe +  check_box( objeto, atributo, {:checked => otros[:checked], :disabled => otros[:disabled]} ) + rotulo + "</div>".html_safe
    else
      ('<div class="elemento' + clase + '" #{title}>' + ( ("<br>" if otros[:abajo]) || "")).html_safe + rotulo + check_box( objeto, atributo, {:checked => otros[:checked], :disabled => otros[:disabled]} ) + "</div>".html_safe
    end
  end

  def final_formulario boton={}
    cadena = '<div class="fila" id="botonguardar"> <div class="elemento_derecha">'.html_safe
    if boton[:submit_disabled] != true
      cadena << submit_tag( boton[:etiqueta]?boton[:etiqueta]:"Guardar", :class => "boton", :onclick => "this.disabled=true")
    end
    cadena += "</div></div>".html_safe
    cadena += "<div class='fila' id='spinner' style='display:none'></div>".html_safe
    cadena += "</form>".html_safe
    cadena += javascript_tag("activaSelectoresChosen();")
    return cadena
  end

  # dibuja un mensage flash
  def mensaje msg
    ("<div id = 'mensaje'>" + msg + "</div>").html_safe if msg
  end

  # dibuja un mensaje flash de exito
  def mensaje_ok msg
    ("<div id = 'mensajeok'>" + msg + "</div>").html_safe if msg
  end

  # dibuja el mensaje de error o de exito
  def mensaje_error objeto, otros={}
    if objeto.class == String && !objeto.blank?
      cadena = '<div id="mensajeerror">'.html_safe
      cadena << objeto.html_safe
    else
      if objeto.blank? || objeto.errors.empty?
        cadena = '<div id="mensajeok">'.html_safe
        cadena << "Los datos se han guardado correctamente.".html_safe unless otros[:borrar]
        cadena << "Se ha eliminado correctamente.".html_safe if otros[:borrar]
      else
        cadena = '<div id="mensajeerror">'.html_safe
        cadena << "Se ha producido un error.".html_safe + "<br>".html_safe
        objeto.errors.each {|a, m| cadena += (m + "<br>").html_safe }
      end
    end
    cadena << "</div>".html_safe
    return cadena
  end

  # Ventana modal (*otros para futuro uso)
  def modal( rotulo, url, titulo, otros={} )
    # OJOOOOO CON ESTO!!!
    link_to rotulo, nil, remote: true, title: titulo,
            onclick: "Modalbox.show('#{url_for(url)}', {title: '#{titulo}', width:820 }); return false;",
            id: (otros[:id]||""), class: (otros[:class]||"")
  end

  # Ventana modal que pide confirmacion para el borrado de un elemento
  def borrado ( rotulo, url, titulo, texto, otros={} )
    # Falta añadir al titulo de la ventana modal el mismo texto superior que llevan las modales sobre la variable de session.
    cadena = '<div style="display:none;" id="'+ (otros[:id] || url[:id].to_s ) +'_borrar" class="elemento_c">'
    cadena << 'Va a eliminar:<br>' unless otros[:no_borrado]
    cadena << '<B>' + texto + '<br><br>'
    cadena << '<div class="fila"><a href="#" onclick="Modalbox.hide()"> Cancelar </a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '
    cadena << link_to( "Confirmar", url, :id => otros[:id].to_s + "_confirmar") unless otros[:ajax]
    cadena << link_to_remote( "Confirmar", :url => url, :html =>  {:id => otros[:id].to_s + "_confirmar"}) if otros[:ajax]
    cadena << '</b></div></div>'
    cadena << "<a id=\"#{ (otros[:id] || url[:id].to_s )  }\" onclick=\"Modalbox.show($('#{ (otros[:id] || url[:id].to_s )  }_borrar'), {title: '" + titulo + "', width: 600}); return false;\" href=\"#\" title='"+ url[:action].to_s + "'>"
    cadena << rotulo
    cadena << "</a>"
    return cadena.html_safe
  end

 # Sustituye al helper de auto_complete para presentar los resultados
 def auto_complete_result_2(entries, field, phrase = nil)
    return unless entries
    items = entries.map { |entry| phrase ? highlight(entry[field], phrase) : h(entry[field]) }
    result = "<ul>"
    items.uniq.each { |li|
      result << "<li>" + li + "</li>"
    }
    result << "<ul>"
    return result.html_safe
  end

  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end

  def controlador_rotulo controlador={}
    rotulo="LibreTPV"
    controladores.each{|elemento| rotulo = elemento[:rotulo] if elemento[:controlador] == controlador}
    return rotulo
  end

  # Devuelve las secciones disponibles para el usuario
  def secciones user=nil
     secciones = [ { seccion: "caja",          url: "/caja/albarans",            title: "Caja"},
                   { seccion: "productos",     url: "/productos/productos/",     title: "Productos"},
                   { seccion: "tesoreria",     url: "/tesoreria/caja/",          title: "Tesorería"},
                   { seccion: "distribuidora", url: "/distribuidora/productos_editorial/", title: "Distribuidora"},
                   { seccion: "admin",         url: "/admin/avisos/",            title: "Administración"} ]
     if user && user.class.name == "User"
       return secciones.select{|sec| user.send("acceso_#{sec[:seccion]}") }
     else
       return secciones
     end
  end

  def controladores controlador={}
    controladores = []
    case params[:seccion]
      when "caja"
        controladores = [ #{ :rotulo => "Pedidos", :controlador => "pedidos" },
                          { :rotulo => "Facturas Clientes" , :controlador => "factura"},
                          { :rotulo => "Clientes" , :controlador => "cliente"},
                          { :rotulo => "Entradas/Salidas de Caja" , :controlador => "caja"},
                          { :rotulo => "Ventas/Devoluciones", :controlador => "albarans" } ]
      when "productos"
        controladores = [ { :rotulo => "Facturas Proveedores", :controlador => "factura"},
                          { :rotulo => "Depósitos", :controlador => "deposito"},
                          { :rotulo => "Albaranes aceptados", :controlador => "albaranes_cerrados"},
                          { :rotulo => "Albaranes de entrada", :controlador => "albarans"},
                          { :rotulo => "Proveedores" , :controlador => "proveedor"},
                          { :rotulo => "Inventario", :controlador => "productos"} ]
      when "tesoreria"
        controladores = [ { :rotulo => "Informes", :controlador => "informe"},
                          { :rotulo => "Libro diario", :controlador => "libro_diario"},
                          { :rotulo => "Posicion global", :controlador => "posicion_global"},
                          { :rotulo => "Arqueo/Cierre de Caja", :controlador => "caja"},
                          { :rotulo => "Facturas de Servicios", :controlador => "factura"}  ]
      when "trueke"
        controladores = [ { :rotulo => "Cambios", :controlador => "cambio"} ]
      when "distribuidora"
        controladores = [ { rotulo: "Facturas librerías", controlador: "factura" },
                          { rotulo: "Albaranes de envío", controlador: "albarans" },
                          { rotulo: "Almacenes", controlador: "almacenes" },
                          { rotulo: "Inventario", controlador: "productos_editorial" }
                        ]
      when "admin"
        controladores = [ #{ :rotulo => "Usuarios", :controlador => "usuarios"},
                          { rotulo: "Backup", controlador: "backup"},
                          { rotulo: "Recuperar Objetos", controlador: "perdidos" },
			                    { rotulo: "Parámetros", controlador: "configuracion"},
                          { rotulo: "Usuarios", controlador: "users"},
                          { rotulo: "Formas de Pago", controlador: "forma_pago"},
                          { rotulo: "Tipos de IVA", controlador: "iva"},
                          { rotulo: "Familias de Productos", controlador: "familia"},
                          { rotulo: "Materias", controlador: "materia"},
                          { rotulo: "Editoriales", controlador: "editorial"},
                          { rotulo: "Autores", controlador: "autor"},
                          { rotulo: "Avisos", controlador: "avisos"} ]

    end
    return controladores
  end

end
