class AlbaranLineasController < ApplicationController


  # Metodos AJAX de Lineas de Albaran

  def lineas
    if params[:factura_id]
      factura = Factura.find_by_id(params[:factura_id])
      @albaran_lineas = []
      factura.albarans.each{|alb| @albaran_lineas += alb.albaran_lineas}
      albaran = factura.albarans.first
    else
      albaran = Albaran.find_by_id(params[:albaran_id])
      @albaran_lineas = albaran.albaran_lineas 
    end

    @formato_xls = true
    respond_to do |format|
      format.xls do
        @tipo = "lineas_deposito" if albaran.proveedor && albaran.deposito
        @tipo = "lineas_compra" if albaran.proveedor && !albaran.deposito
        @tipo = "lineas_venta" unless albaran.proveedor
        codigo = albaran.factura.codigo if albaran.factura && albaran.factura.codigo && albaran.factura.codigo != "N/A"
        codigo ||= albaran.codigo
        codigo += " (*)" if albaran.factura && albaran.factura.codigo && albaran.factura.codigo == "N/A"
        fecha = (albaran.factura ? albaran.factura.fecha.to_s : nil) || albaran.fecha.to_s
        fecha += " / Fecha Devolución: " + albaran.fecha_devolucion.to_s if albaran.deposito
        tipo = "Albarán"
        if albaran.cliente
          @xls_head = "Venta " + codigo + " / Cliente: " + albaran.cliente.nombre + " / Fecha: " + fecha
        else
          tipo = "Depósito" if albaran.deposito
          tipo = "Factura" if albaran.factura_id
          @xls_head = tipo + ": " + codigo + " / Proveedor: " + albaran.proveedor.nombre + " / Fecha: " + fecha
        end
        @xls_head += "  / ALBARAN ABIERTO" if !albaran.cerrado
        @objetos = @albaran_lineas
        @xls_title = "Albaran " + albaran.codigo
        render 'comunes_xls/listado', :layout => false
      end 
      format.html do
        render :update do |page|
          page.replace_html params[:update], :partial => "lineas"
        end
      end
    end
  end

  def editar
    @albaran_linea = AlbaranLinea.find(params[:id])
    render :partial => "editar", :albaran_id => params[:albaran_id]
  end

  def modificar
    @albaran_linea = AlbaranLinea.find(params[:id])
    @albaran_linea.update_attributes params[:albaran_linea]
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

  def asignar_linea
    albaran = Albaran.find_by_id params[:albaranlinea][:albaran_id]
    if albaran && !albaran.cerrado
      albaranlinea = params[:id] ? AlbaranLinea.find(params[:id]) : AlbaranLinea.new
      albaranlinea.producto_id = params[:producto][:id] if params[:producto]
      params[:albaranlinea][:cantidad] = 1 unless params[:albaranlinea][:cantidad] && params[:albaranlinea][:cantidad] != ""
      params[:albaranlinea][:descuento] = 0 unless params[:albaranlinea][:descuento] && params[:albaranlinea][:descuento] != ""
      albaranlinea.update_attributes params[:albaranlinea]
      if !Albaran.find_by_id(params[:albaranlinea][:albaran_id]).proveedor.nil? && params[:precios_relacionados]
        if params[:precios_relacionados][0].to_s == "true"
          producto = Producto.find_by_id(params[:producto][:id])
          preciodeventa = producto.precio
          albaranlinea.precio_compra = preciodeventa / (1 + producto.familia.iva.valor.to_f/100)
        else
          albaranlinea.precio_compra = params[:albaranlinea][:precio_compra].to_f
        end
        albaranlinea.save
      end

    end
    #flash[:error] = albaranlinea if albaranlinea.errors
    redirect_to :controller => :albarans, :action => :editar, :id => albaranlinea.albaran_id
  end

  def borrar 
    albaran = Albaran.find_by_id params[:albaran_id]
    albaranlinea = AlbaranLinea.find_by_id params[:id] 
    if albaranlinea && albaran && !albaran.cerrado
      albaranlinea.destroy
    end
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

	# Aplica el acumulado de una linea
  def usar_acumulado
    albaran = Albaran.find_by_id params[:albaran_id]
    albaranlinea = AlbaranLinea.find_by_id params[:id]
    if albaranlinea && albaran.cliente
      albaranlinea.nueva_linea_descuento
    end
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

end
