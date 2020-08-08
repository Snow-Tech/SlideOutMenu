//
//  ViewController.swift
//  SlideOutMenu
//
//  Created by Brian Hashirama on 8/8/20.
//  Copyright © 2020 Brian-Michael. All rights reserved.
//

import UIKit

class HomeController: UITableViewController {
    
    fileprivate let menuController = SideMenuController()
    fileprivate let menuWidth: CGFloat = 300
    fileprivate let velocityValue: CGFloat = 500
    fileprivate var isMenuOpen = false
    fileprivate let darkview = UIView()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .red
        setupNavigationItems()
        setupMenuViews()
        
        setupPanGesture()
        setupDarkView()
    }
    
    
    
    
    
    @objc func handleOpen(){
        //animar o menu quando aparece
        isMenuOpen = true
        let transform = CGAffineTransform(translationX: menuWidth, y: 0)
        performAnimations(transform: transform)
        
        
    }
    
    @objc func handleHide(){
        //animar o menu quando volta
        isMenuOpen = false
        performAnimations(transform: .identity)
    }
    
    
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        
        if gesture.state == .changed {
            var x = translation.x
            
            //verifica quando o menu está aberto, e se estiver, podemos delizar para esuqerda para ele fechar
            if isMenuOpen {
                x += menuWidth
            }
            
            
            // quando arrastamos ele arrasta tanto para esquerda como na direita, entaão
            x = min(menuWidth, x) // o valor minimo que ele pode abrir de x que seria o cumprimento total do menu de 300
            x = max(0, x) //para nao deslizar para direita
            let transform = CGAffineTransform(translationX: x, y: 0)
            menuController.view.transform = transform
            navigationController?.view.transform = transform
            
            darkview.transform = transform
            darkview.alpha = x/menuWidth
            
        } else if gesture.state == .ended {
            handleEnded(gesture: gesture)
        }
        
        
    }
    
    
    //Darkview 
    fileprivate func setupDarkView(){

        let mainWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        mainWindow?.addSubview(darkview)
        darkview.alpha = 0
        darkview.frame = mainWindow?.frame ?? .zero
        darkview.backgroundColor = UIColor(white: 0, alpha: 0.7)
        darkview.isUserInteractionEnabled = false
        
    }
    
    
    
    
    
    
    fileprivate func setupPanGesture() {
        //Pan Gesture
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.view.addGestureRecognizer(pangesture)
    }
    
    fileprivate func handleEnded(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view) // velocidade quando fazes o swipe o deslize
        
        //aqui ele verifica se quando estivermos a fechar o menu, se ele esta na metado do cumprimento para poder fechar completamente, o abs torna o valor negativo em positivo
        if isMenuOpen {
            if abs(velocity.x) > velocityValue {
                handleHide()
                return
            }
            if abs(translation.x) < menuWidth / 2 {
                handleOpen()
            }else {
                handleHide()
            }
        }else {
            
            if velocity.x > velocityValue {
                handleOpen()
                return
            }
            
            // quando estivermos a arrastar o menu para o lado direito, ele começa a verificar se o valor é menor que a metade do cumorimento total, se for menor ele esconde, se for maior ele abre
            if translation.x < menuWidth / 2 {
                handleHide()
            } else {
                handleOpen()
            }
        }
    }
    
    
    
    
    fileprivate func performAnimations(transform: CGAffineTransform){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.menuController.view.transform = transform
            self.navigationController?.view.transform = transform
            
            //Darkview
            self.darkview.transform = transform
            self.darkview.alpha = transform == .identity ? 0 : 1

            
        })
    }
    
    
    
    fileprivate func setupMenuViews(){
        menuController.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: self.view.frame.height)
        let mainWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        mainWindow?.addSubview(menuController.view)
        addChild(menuController)
    }
    
    
    fileprivate func setupNavigationItems(){
        navigationItem.title = "Home"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(handleOpen))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(handleHide))
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cellid")
        cell.textLabel?.text = "Row: \(indexPath.row)"
        return cell
    }
    
}

