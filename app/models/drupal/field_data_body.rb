#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2015 Santiago Ramos <sramos@sitiodistinto.net> 
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


class Drupal::FieldDataBody < Drupal

  belongs_to :product, class_name: 'Drupal::Node', foreign_key: :entity_id

  validate :valores_por_defecto
  validates_presence_of :product, :message => "El stock debe corresponder a un producto."

  # Genera los valores por defecto para algunos de los campos
  def valores_por_defecto
    entity_type ||= "node"
    bundle ||= "product" 
    revision_id ||= entity_id
    language ||= "und"
    delta ||= 0
    body_format ||= "text_only"
  end

end
