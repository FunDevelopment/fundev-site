/**
 *  fundev_world.fun
 *
 *  3D scene for Fun web site
 *
 **/

site fundev {

    adopt three
    
    initial_scene_name = "home"
    
    /--- materials ---/

    phong_material blue_material {
        undecorated color = 0x3333CC
    }
    
    
    /--- objects ---/
    
    mesh blue_cube {
        geometry geo = box_geometry(10, 10, 10)
        material mat = blue_material
        position pos = position(0, 2, 0)
        
        boolean is_pointable = true
    }

    
    /--- lights ---/

    object_group light_group {
    
        point_light(0xFF0000) bright_red_light {
            position pos = position(30, 13, 20)
        }
    
        point_light(0x00FF00) bright_green_light {
            position pos = position(-30, 13, 20)
        }
    
        point_light(0x5555FF) bright_blue_light {
            position pos = position(0, 50, 0)
        }
    
        point_light(0xAAAAAA) soft_white_light {
            position pos = position(0, 2, 40)
        }
    }

    scene home {
        three_object[] objs = [
            blue_cube,
            light_group
        ]
            
        next_frame [/
            blue_cube.rotation.x -= 0.01;
            blue_cube.rotation.y += 0.01;
            blue_cube.rotation.z -= 0.02;
        /]
    }

}
