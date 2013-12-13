module Riyic
    module AttributeMixin
        # si extendemos unha clase con este modulo os metodos fanse de clase
        # si incluimos esta clase os metodos fanse de instancia
        
        def attr_setter(*method_names)
             method_names.each do |name|
                send :define_method, name do |data|
                    instance_variable_set "@#{name}".to_sym, data 
                end
            end
        end
            
        def varargs_setter(*method_names)
                
            method_names.each do |name|
                send :define_method, name do |*data|
                    instance_variable_set "@#{name}".to_sym, data
                end
            end
        end

    end
end
