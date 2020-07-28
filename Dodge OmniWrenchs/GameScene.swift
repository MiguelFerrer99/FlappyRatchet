//
//  GameScene.swift
//  Dodge OmniWrenchs
//
//  Created by Miguel Ferrer Fornali on 05/07/2020.
//

import SpriteKit
import GameplayKit
import AVKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*  La propiedad categoryBitMask es un número que define el tipo de objeto que el cuerpo fisico del nodo tendrá y es considerado para las colisiones y contactos.
        La propiedad collisionBitMask es un número que define con cuales categorias de objetos este nodo deberia colisionar.
        La propiedad contactTestBitMask es un número que define cueles colisiones nos seran notificadas.
        
        Nota:
         Si le das a un nodo numeros de Collision Bitmask pero no les das numeros de contact test Bitmask, significa que los nodos podran colisionar pero no tendras manera de saber cuando ocurrio en código (no se notificara al sistema).
         Si haces lo contrario (no Collision Bitmask pero si Contact Test Bitmask), no "chocaran" o colisionaran, pero el sistema te podra notificar el momento en que tuvieron contacto.
         Si a las dos propiedades les das valores entonces notificado y a su vez los nodos podran colisionar.
         Automaticamente los cuerpos fisicos tienen su propiedad de Collision Bitmask = a TODO y su Contact Bitmask = Nada */
    
    private let miClave = "miClave"
    var ventanaOpcionesAbierta = false
    var record:Int = 0
    var cuentaAtras = 3
    var labelCuentaAtrasPause = SKLabelNode()
    var labelPuntuacionActual = SKLabelNode()
    var labelRecordInicio = SKLabelNode()
    var labelRecordFinal = SKLabelNode()
    var zurkon = SKSpriteNode()
    var fondo_base = SKSpriteNode()
    var llave1 = SKSpriteNode()
    var llave2 = SKSpriteNode()
    let suelo = SKNode() //Se utiliza un nodo normal (no Sprite) cuando queremos que esté vacío (sin textura), aunque se pueden crear nodos Sprite vacíos
    var espacio = SKSpriteNode()
    var ventanaPause = SKSpriteNode()
    var ventanaOpciones = SKSpriteNode()
    var botonVolver = SKSpriteNode()
    var botonReanudar = SKSpriteNode()
    var labelPuntuacion = SKLabelNode()
    var labelInicio = SKLabelNode()
    var labelFinal = SKLabelNode()
    var labelGameOver = SKLabelNode()
    var puntuacion = 0
    var timerLlaves = Timer()
    var timerCuentaAtras = Timer()
    var gameOver = false
    var musicaFondo = SKAudioNode()
    var sonidoGameOver = SKAudioNode()
    var botonOpciones = SKSpriteNode()
    var botonPause = SKSpriteNode()
    let fadeOut = SKAction.fadeOut(withDuration: 0.3)
    let fadeIn = SKAction.fadeIn(withDuration: 0.3)
    let texturaZurkon1 = SKTexture(imageNamed: "zurkon_textura1.png")
    let texturaZurkon2 = SKTexture(imageNamed: "zurkon_textura2.png")
    let texturaZurkon3 = SKTexture(imageNamed: "zurkon_textura3.png")
    let texturaZurkon4 = SKTexture(imageNamed: "zurkon_textura4.png")
    enum tipoNodo:UInt32 { //tipos de nodos que colisionen entre ellos
        case zurkon = 1
        case llave_o_suelo = 2
        case espacioLlaves = 4
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self //Esta clase de 'physicsWorld' se va a delegar en esta misma clase 'GameScene.swift'
        if(obtenerPreferencias() != 0) {
            record = obtenerPreferencias()
        }
        reiniciarJuego()
    }
    
    func guardarPreferencias() {
        //Guardar las preferencias
        UserDefaults.standard.set(record, forKey:miClave)
        UserDefaults.standard.synchronize()
    }

    func obtenerPreferencias()->Int {
        //Obtener las preferencias
        record = UserDefaults.standard.integer(forKey:miClave)
        return record
    }
    
    func borrarPreferencias() {
        //Borrar las preferencias
        UserDefaults.standard.removeObject(forKey:miClave)
        UserDefaults.standard.synchronize()
    }
    
    func añadirLabelPuntuacion() {
        labelPuntuacion.fontName = "RGFuture-Italic"
        labelPuntuacion.fontSize = 300
        labelPuntuacion.zPosition = 2
        labelPuntuacion.text = "0"
        labelPuntuacion.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 600)
        self.addChild(labelPuntuacion)
        labelPuntuacion.isHidden = true
    }
    
    func añadirLabelCuentaAtrasPause() {
        labelCuentaAtrasPause.fontName = "RGFuture-Italic"
        labelCuentaAtrasPause.fontSize = 400
        labelCuentaAtrasPause.text = ""
        labelCuentaAtrasPause.zPosition = 2
        labelCuentaAtrasPause.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        self.addChild(labelCuentaAtrasPause)
        labelCuentaAtrasPause.isHidden = true
    }
    
    @objc func actualizarCuentaAtrasPause() {
        if(cuentaAtras == 3) {
            labelCuentaAtrasPause.text = String(cuentaAtras)
            cuentaAtras-=1
        }
        else if(cuentaAtras == 2) {
            labelCuentaAtrasPause.text = String(cuentaAtras)
            cuentaAtras-=1
        }
        else if(cuentaAtras == 1) {
            labelCuentaAtrasPause.text = String(cuentaAtras)
            cuentaAtras-=1
        }
        else if(cuentaAtras == 0) {
            self.isPaused = false
            botonPause.isHidden = false
            timerCuentaAtras.invalidate()
            labelCuentaAtrasPause.text = ""
            labelCuentaAtrasPause.isHidden = true
            timerLlaves = Timer.scheduledTimer(timeInterval:2, target:self, selector:#selector(self.añadirLlaves_y_Espacios), userInfo:nil, repeats:true) //Timer para repetir la funcion de 'añadirLlaves' cada 2 segundos
        }
    }
    
    func añadirLabelPuntuacionActual() {
        labelPuntuacionActual.fontName = "RGFuture-Italic"
        labelPuntuacionActual.fontSize = 80
        labelPuntuacionActual.zPosition = 2
        labelPuntuacionActual.text = "YOUR SCORE: \(puntuacion)"
        labelPuntuacionActual.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 100)
        labelPuntuacionActual.isHidden = true
        self.addChild(labelPuntuacionActual)
    }
    
    func añadirLabelRecordInicio() {
        labelRecordInicio.fontName = "RGFuture-Italic"
        labelRecordInicio.fontSize = 140
        labelRecordInicio.zPosition = 2
        labelRecordInicio.text = "¡BEST SCORE: \(record)!"
        
        //SECUENCIA QUE HACE QUE EL LABEL DEL INICIO PARPADEE
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let secuenciaParpadeo = SKAction.sequence([fadeIn,fadeOut])
        let parpadeoInfinito = SKAction.repeatForever(secuenciaParpadeo)
        
        labelRecordInicio.run(parpadeoInfinito)
        labelRecordInicio.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 350)
        self.addChild(labelRecordInicio)
        labelRecordInicio.isHidden = false
    }
    
    func añadirLabelRecordFinal() {
        labelRecordFinal.fontName = "RGFuture-Italic"
        labelRecordFinal.fontSize = 110
        labelRecordFinal.zPosition = 2
        labelRecordFinal.text = "BEST SCORE: \(record)"
        labelRecordFinal.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 300)
        self.addChild(labelRecordFinal)
        labelRecordFinal.isHidden = true
    }
    
    func añadirLabelInicio() {
        
        labelInicio.fontName = "RGFuture-Italic"
        labelInicio.fontSize = 90
        labelInicio.zPosition = 2
        labelInicio.text = "TOUCH THE SCREEN TO START"
        labelInicio.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 650)

        //SECUENCIA QUE HACE QUE EL LABEL DEL INICIO PARPADEE
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let secuenciaParpadeo = SKAction.sequence([fadeIn,fadeOut])
        let parpadeoInfinito = SKAction.repeatForever(secuenciaParpadeo)
        
        self.addChild(labelInicio)
        labelInicio.isHidden = false
        labelInicio.run(parpadeoInfinito)
    }
    
    func añadirLabelGameOver() {
        
        labelGameOver.fontName = "RGFuture-Italic"
        labelGameOver.fontSize = 200
        labelGameOver.zPosition = 2
        labelGameOver.text = "GAME OVER"
        labelGameOver.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 550)
        self.addChild(labelGameOver)
        labelGameOver.isHidden = true
    }
    
    func añadirLabelFinal() {
        
        labelFinal.fontName = "RGFuture-Italic"
        labelFinal.fontSize = 65
        labelFinal.zPosition = 2
        labelFinal.text = "TOUCH THE SCREEN TO PLAY A NEW GAME"
        labelFinal.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 700)
        
        //SECUENCIA QUE HACE QUE EL LABEL DEL INICIO PARPADEE
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.8)
        let secuenciaParpadeo = SKAction.sequence([fadeIn,fadeOut])
        let parpadeoInfinito = SKAction.repeatForever(secuenciaParpadeo)
        
        self.addChild(labelFinal)
        labelFinal.isHidden = true
        labelFinal.run(parpadeoInfinito)
    }
    
    func añadirZurkon() {
        
        let texturaZurkon1 = SKTexture(imageNamed: "zurkon_textura1.png")
        zurkon = SKSpriteNode(texture: texturaZurkon1)
        zurkon.position = CGPoint(x:self.frame.midX - 120, y:self.frame.midY + 80)
        zurkon.zPosition = 1
        zurkon.physicsBody = SKPhysicsBody(circleOfRadius: texturaZurkon1.size().width/2)
        zurkon.physicsBody!.isDynamic = false //Así no se cae
        zurkon.physicsBody?.allowsRotation = false
        
        zurkon.physicsBody!.categoryBitMask = tipoNodo.zurkon.rawValue
        zurkon.physicsBody!.collisionBitMask = tipoNodo.llave_o_suelo.rawValue
        zurkon.physicsBody!.contactTestBitMask = tipoNodo.llave_o_suelo.rawValue | tipoNodo.espacioLlaves.rawValue
        
//        zurkon.run(animacionInfinita)
        self.addChild(zurkon)
    }
    
    func añadirFondo() {
        
        let texturaFondoBase = SKTexture(imageNamed: "fondo_base.png")
        let movimientoFondo = SKAction.move(by: CGVector(dx:-self.frame.width, dy:0), duration:3)
        let movimientoFondoOrigen = SKAction.move(by: CGVector(dx:self.frame.width, dy:0), duration:0)
        let movimientoInfinitoFondo = SKAction.repeatForever(SKAction.sequence([movimientoFondo,movimientoFondoOrigen]))
        
        var i:CGFloat = 0
        while(i<2) {
            fondo_base = SKSpriteNode(texture: texturaFondoBase)
            fondo_base.position = CGPoint(x:self.frame.width * i, y:self.frame.midY)
            fondo_base.size.height = self.frame.height
            fondo_base.size.width = self.frame.width
            fondo_base.zPosition = -2
            fondo_base.run(movimientoInfinitoFondo)
            self.addChild(fondo_base)
            i += 1
        }
        fondo_base.speed = 1
    }
    
    func añadirSuelo() {
        
        suelo.position = CGPoint(x:-self.frame.midX, y:-self.frame.height/2 )
        suelo.physicsBody = SKPhysicsBody(rectangleOf:CGSize(width:self.frame.width, height:1))
        suelo.physicsBody!.isDynamic = false //Así no se cae
        
        suelo.physicsBody!.categoryBitMask = tipoNodo.llave_o_suelo.rawValue
        suelo.physicsBody!.collisionBitMask = tipoNodo.zurkon.rawValue
        suelo.physicsBody!.contactTestBitMask = tipoNodo.zurkon.rawValue
        
        self.addChild(suelo)
    }
    
    @objc func añadirLlaves_y_Espacios() {
        
        let gapDificultad = zurkon.size.height * 1.2
        let cantidadMovimientoAleatorio = CGFloat(arc4random() % UInt32(self.frame.height/2)) //Numero aleatorio entre 0 y la mitad del alto de la pantalla
        let compensacionLlaves =  cantidadMovimientoAleatorio - self.frame.height / 4
        
        let moverLlaves_y_Espacios = SKAction.move(by: CGVector(dx:-3*self.frame.width, dy:0), duration:TimeInterval(self.frame.width/120))
        let borrarLlaves_y_Espacios = SKAction.removeFromParent()
        let mover_y_borrarLlaves_y_Espacios = SKAction.sequence([moverLlaves_y_Espacios,borrarLlaves_y_Espacios]) //De esta manera, no se acumulan los nodos que ya no estan visibles en la pantalla, ahorramos recursos
        
        let texturaLlave2 = SKTexture(imageNamed:"llave2.png")
        let sizeLlave2 = CGSize(width:texturaLlave2.size().width, height:texturaLlave2.size().height + 50)
        llave2 = SKSpriteNode(texture:texturaLlave2)
        llave2.position = CGPoint(x:self.frame.midX + self.frame.width, y:self.frame.midY + (texturaLlave2.size().height/2) + gapDificultad + compensacionLlaves)
        llave2.zPosition = 0
        llave2.physicsBody = SKPhysicsBody(rectangleOf:sizeLlave2)
        llave2.physicsBody!.isDynamic = false
        llave2.physicsBody!.categoryBitMask = tipoNodo.llave_o_suelo.rawValue
        llave2.physicsBody!.collisionBitMask = tipoNodo.zurkon.rawValue
        llave2.physicsBody!.contactTestBitMask = tipoNodo.zurkon.rawValue
        llave2.run(mover_y_borrarLlaves_y_Espacios)
        self.addChild(llave2)
        
        let texturaLlave1 = SKTexture(imageNamed:"llave1.png")
        let sizeLlave1 = CGSize(width:texturaLlave1.size().width, height:texturaLlave1.size().height - 25)
        llave1 = SKSpriteNode(texture:texturaLlave1)
        llave1.position = CGPoint(x:self.frame.midX + self.frame.width, y:self.frame.midY - (texturaLlave1.size().height/2) - gapDificultad + compensacionLlaves)
        llave1.zPosition = 0
        llave1.physicsBody = SKPhysicsBody(rectangleOf:sizeLlave1)
        llave1.physicsBody!.isDynamic = false
        llave1.physicsBody!.categoryBitMask = tipoNodo.llave_o_suelo.rawValue
        llave1 .physicsBody!.collisionBitMask = tipoNodo.zurkon.rawValue
        llave1.physicsBody!.contactTestBitMask = tipoNodo.zurkon.rawValue
        llave1.run(mover_y_borrarLlaves_y_Espacios)
        self.addChild(llave1)
        
        //AÑADIMOS LOS ESPACIOS
        espacio = SKSpriteNode()
        espacio.position = CGPoint(x:self.frame.midX + self.frame.width, y:self.frame.midY + compensacionLlaves)
        espacio.physicsBody = SKPhysicsBody(rectangleOf:CGSize(width:texturaLlave2.size().width, height:gapDificultad))
        espacio.physicsBody!.isDynamic = false //No se cae por la gravedad
        espacio.zPosition = 1 //A la altura del zurkon
        espacio.physicsBody!.categoryBitMask = tipoNodo.espacioLlaves.rawValue
        espacio.physicsBody!.collisionBitMask = 0 //No queremos que colisione con nada
        espacio.physicsBody!.contactTestBitMask = tipoNodo.zurkon.rawValue
        espacio.run(mover_y_borrarLlaves_y_Espacios)
        self.addChild(espacio)
    }
    
    func añadirMusica() {
        
        if let musicaFondoURL = Bundle.main.url(forResource: "musicaFondo", withExtension: "mp3") {
            musicaFondo = SKAudioNode(url: musicaFondoURL)
            addChild(musicaFondo)
        } else { print("Error creando la url de la musicaFondo") }
        
        /*if let sonidoGameOverURL = Bundle.main.url(forResource: "sonidoGameOver", withExtension: "mp3") {
            sonidoGameOver = SKAudioNode(url: sonidoGameOverURL)
            addChild(sonidoGameOver)
        } else { print("Error creando la url del sonidoGameOver") }*/
    }
    
    func añadirBotonOpciones() {
        
        let texturaBotonOpciones = SKTexture(imageNamed: "botonOpciones.png")
        botonOpciones = SKSpriteNode(texture: texturaBotonOpciones)
        botonOpciones.size = CGSize(width: 350, height: 250)
        botonOpciones.zPosition = 2
        botonOpciones.position = CGPoint(x: self.frame.midX + 330, y: self.frame.midY + 800)
        addChild(botonOpciones)
        botonOpciones.isHidden = false
        
        //Estas 2 líneas de código son necesarias para cualquier toque en el nodo sea detectado
        botonOpciones.name = "opciones"
        botonOpciones.isUserInteractionEnabled = false
    }
    
    func añadirBotonPause() {
        
        let texturaBotonPause = SKTexture(imageNamed: "botonPause.png")
        botonPause = SKSpriteNode(texture: texturaBotonPause)
        botonPause.size = CGSize(width: 350, height: 250)
        botonPause.zPosition = 2
        botonPause.position = CGPoint(x: self.frame.midX - 330, y: self.frame.midY + 800)
        addChild(botonPause)
        botonPause.isHidden = true
        
        //Estas 2 líneas de código son necesarias para cualquier toque en el nodo sea detectado
        botonPause.name = "pause"
        botonPause.isUserInteractionEnabled = false
    }
    
    func actualizarRecord() {
        
        record = obtenerPreferencias()
    
        if(puntuacion > record) {
            record = puntuacion
            guardarPreferencias() //Guardamos el record en las preferencias
            labelRecordFinal.fontSize = 100
            labelRecordFinal.text = "!YOU BROKE THE RECORD!"
        }
        else if(puntuacion == record) {
            labelRecordFinal.text = "BEST SCORE: \(record)"
        }
        else if(puntuacion < record) {
            labelRecordFinal.text = "BEST SCORE: \(record)"
        }
    }
    
    func reiniciarJuego() {
        añadirMusica()
        //sonidoGameOver.run(SKAction.stop()) //CUANDO SALE EL MENU DE INICIO, PARAMOS EL SONIDO DE GAME OVER
        musicaFondo.run(SKAction.play()) //CUANDO SALE EL MENU DE INICIO, EMPIEZA A SONAR LA MUSICA DE FONDO
        añadirLabelPuntuacion()
        añadirLabelInicio()
        añadirLabelRecordInicio()
        añadirLabelRecordFinal()
        añadirLabelGameOver()
        añadirLabelFinal()
        añadirZurkon()
        añadirFondo()
        añadirSuelo()
        añadirBotonOpciones()
        añadirBotonPause()
        añadirLabelPuntuacionActual()
        añadirVentanaPauseConBotonReanudar()
        añadirLabelCuentaAtrasPause()
        añadirVentanaOpciones()
    }
    
    func añadirVentanaPauseConBotonReanudar() {
        
        let texturaVentanaPause = SKTexture(imageNamed: "ventanaPause.png")
        ventanaPause = SKSpriteNode(texture: texturaVentanaPause)
        ventanaPause.size = CGSize(width:600, height:400)
        ventanaPause.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ventanaPause.isHidden = true
        ventanaPause.zPosition = 2
        self.addChild(ventanaPause)
        
        let texturaBotonReanudar = SKTexture(imageNamed: "botonReanudar.png")
        botonReanudar = SKSpriteNode(texture: texturaBotonReanudar)
        botonReanudar.size = CGSize(width:300, height:100)
        botonReanudar.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 75)
        botonReanudar.isHidden = true
        botonReanudar.zPosition = 3
        self.addChild(botonReanudar)
        
        //Estas 2 líneas de código son necesarias para cualquier toque en el nodo del 'botonReanudar' sea detectado
        botonReanudar.name = "reanudar"
        botonReanudar.isUserInteractionEnabled = false
    }
    
    func añadirVentanaOpciones() {
        
        let texturaVentanaOpciones = SKTexture(imageNamed: "ventanaOpciones.png")
        ventanaOpciones = SKSpriteNode(texture: texturaVentanaOpciones)
        ventanaOpciones.size = CGSize(width:850, height:550)
        ventanaOpciones.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        ventanaOpciones.isHidden = true
        ventanaOpciones.zPosition = 2
        self.addChild(ventanaOpciones)
        
        let texturaBotonVolver = SKTexture(imageNamed: "botonVolver.png")
        botonVolver = SKSpriteNode(texture: texturaBotonVolver)
        botonVolver.size = CGSize(width:300, height:100)
        botonVolver.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 170)
        botonVolver.isHidden = true
        botonVolver.zPosition = 3
        self.addChild(botonVolver)
        
        //Estas 2 líneas de código son necesarias para cualquier toque en el nodo del 'botonVolver' sea detectado
        botonVolver.name = "volver"
        botonVolver.isUserInteractionEnabled = false
    }
    
    func ponerPauseJuego() {
        print("PAUSE")
        botonPause.isHidden = true
        self.isPaused = true
        ventanaPause.isHidden = false
        botonReanudar.isHidden = false
        labelCuentaAtrasPause.text = ""
        timerLlaves.invalidate() //Invalidamos el timer de creacion de llaves para que deje de crear llaves durante la 'ventanaPause'
        cuentaAtras = 3
    }
    
    func reanudarJuego() {
        print("REANUDAR")
        ventanaPause.isHidden = true
        botonReanudar.isHidden = true
        labelCuentaAtrasPause.isHidden = false
        timerCuentaAtras = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(self.actualizarCuentaAtrasPause), userInfo:nil, repeats:true) //Timer para repetir la funcion de 'actualizaCuentaAtras' cada 1 segundo
    }
    
    func abrirOpciones() {
        botonOpciones.isHidden = true
        ventanaOpciones.isHidden = false
        botonVolver.isHidden = false
    }
    
    func cerrarOpciones() {
        botonOpciones.isHidden = false
        ventanaOpciones.isHidden = true
        botonVolver.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //Esta función se ejecuta en cuanto el usuario toca la pantalla
        
        //Codigo para detectar en que nodo ha sido cada toque que se hace en la pantalla
        for touch in touches {
            let location = touch.location(in: self)
            let nodoTocado:SKNode = self.atPoint(location)
            if(nodoTocado.name == "opciones") {
                abrirOpciones()
                ventanaOpcionesAbierta = true
            }
            else if(nodoTocado.name == "volver") {
                cerrarOpciones()
                ventanaOpcionesAbierta = false
                return //El 'return' sirve para acabar la funcion 'touchBegan' de golpe
            }
            else if(nodoTocado.name == "pause") {
                ponerPauseJuego()
            }else if(nodoTocado.name == "reanudar") {
                reanudarJuego()
            }
        }

        if(ventanaOpcionesAbierta == false)
        {
            if(labelInicio.isHidden == false) //CASO EN EL QUE SE TOCA LA PANTALLA DE INICIO, CUANDO NO SE HA EMPEZADO A JUGAR AÚN
            {
                labelInicio.isHidden = true
                labelPuntuacion.isHidden = false
                labelRecordInicio.isHidden = true
                botonOpciones.run(fadeOut)
                botonPause.run(fadeIn)
                botonPause.isHidden = false
                
                zurkon.physicsBody!.isDynamic = true //Así se cae
                zurkon.physicsBody!.velocity = CGVector(dx:0, dy:0)
                zurkon.physicsBody!.applyImpulse(CGVector(dx:0, dy:220))
                
                let animacionImpulsoZurkon = SKAction.animate(with: [texturaZurkon2,texturaZurkon3,texturaZurkon4,texturaZurkon1], timePerFrame: 0.1)
                zurkon.run(animacionImpulsoZurkon)
                
                timerLlaves = Timer.scheduledTimer(timeInterval:2, target:self, selector:#selector(self.añadirLlaves_y_Espacios), userInfo:nil, repeats:true) //Timer para repetir la funcion de 'añadirLlaves' cada 2 segundos
            }
            else if(labelInicio.isHidden == true)
            {
                if(gameOver == false) { //CASO EN QUE SE TOCA LA PANTALLA DURANTE EL JUEGO
                    
                    zurkon.physicsBody!.isDynamic = true //Así se cae
                    zurkon.physicsBody!.velocity = CGVector(dx:0, dy:0)
                    zurkon.physicsBody!.applyImpulse(CGVector(dx:0, dy:220))
                    
                    let animacionImpulsoZurkon = SKAction.animate(with: [texturaZurkon2,texturaZurkon3,texturaZurkon4,texturaZurkon1], timePerFrame: 0.1)
                    zurkon.run(animacionImpulsoZurkon)
                }
                else if(gameOver == true) { //CASO EN QUE SE TOCA LA PANTALLA CUANDO SE HA MUERTO EL ZURKON
                    gameOver = false
                    puntuacion = 0
                    self.speed = 1
                    zurkon.physicsBody!.applyImpulse(CGVector(dx:0, dy:0))
                    labelFinal.isHidden = true
                    labelGameOver.isHidden = true
                    self.removeAllChildren()
                    reiniciarJuego()
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Esta funcion se activa cuando dos nodos (A y B) entran en contacto
        let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB

        if((cuerpoA.categoryBitMask == tipoNodo.zurkon.rawValue && cuerpoB.categoryBitMask == tipoNodo.espacioLlaves.rawValue) || (cuerpoB.categoryBitMask == tipoNodo.zurkon.rawValue && cuerpoA.categoryBitMask == tipoNodo.espacioLlaves.rawValue)) {
            //CASO EN EL QUE EL ZURKON ENTRA EN CONTACTO CON EL ESPACIO ENTRE LLAVES
            puntuacion += 1
            labelPuntuacion.text = String(puntuacion)
        }
        else if((cuerpoA.categoryBitMask == tipoNodo.zurkon.rawValue && cuerpoB.categoryBitMask == tipoNodo.llave_o_suelo.rawValue) || (cuerpoB.categoryBitMask == tipoNodo.zurkon.rawValue && cuerpoA.categoryBitMask == tipoNodo.llave_o_suelo.rawValue)) {
            //CASO EN EL QUE EL ZURKON HA CHOCADO CON EL SUELO O LAS LLAVES
            zurkon.physicsBody!.isDynamic = false //Una vez toca el suelo o las llaves, le quitamos que sea dinámico, para evitar que vuelva a detectar una colision cuando ya se ha chocado
            zurkon.isHidden = true
            gameOver = true
            fondo_base.speed = 0.5 //La velocidad del nodo del fondo se va reduciendo
            timerLlaves.invalidate() //Invalidamos el timer para que no siga creando nodos
            añadirFondo()
            labelPuntuacion.isHidden = true
            labelGameOver.run(fadeIn)
            labelGameOver.isHidden = false
            musicaFondo.run(SKAction.stop()) //PARAMOS LA MUSICA DE FONDO CUANDO EL ZURKON CHOCA CONTRA EL SUELO O LAS LLAVES
            //sonidoGameOver.run(SKAction.play()) //REPRODUCIMOS EL SONIDO DE GAME OVER
            labelFinal.run(fadeIn)
            labelFinal.isHidden = false
            botonPause.run(fadeOut)
            botonPause.isHidden = true
            
            labelPuntuacionActual.text = "YOUR SCORE: \(puntuacion)"
            labelPuntuacionActual.run(fadeIn)
            labelPuntuacionActual.isHidden = false
            
            //Actualizamos record y lo mostramos por pantall
            actualizarRecord()
            labelRecordFinal.isHidden = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
