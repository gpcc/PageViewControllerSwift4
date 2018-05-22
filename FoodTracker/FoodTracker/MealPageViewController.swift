//
//  MealPageViewController.swift
//  FoodTracker
//
//  Created by Gema Parra Cabrera on 14/4/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//


import UIKit
import os.log

class MealPageViewController: UIPageViewController, UIPageViewControllerDataSource , UIPageViewControllerDelegate{
    
    // MARK: Properties
    @IBOutlet weak var save: UIBarButtonItem!
   
    var numberOfPages = 0
    var meals: [Meal] = []
    var index = 0
    var vista: ViewController? = nil
    var veces = 0
    var primero: Bool = true
    var pageControl = UIPageControl()
    var primeraEjecucion : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Inicializamos el número de páginas al número de comidas existentes
        numberOfPages = meals.count
        
        //Creamos las vistas para las comidas a partir de la fila seleccionada (index)
        setViewControllers([createViewController(pageNumber: index, nombreComida: meals[index].name, photo: meals[index].photo!, rating: meals[index].rating)], direction: .forward, animated: false, completion: nil)
        
        navigationItem.title = meals[index].name

        self.dataSource = self
        
        self.delegate = self
        configurePageControl()
    }
    
    
    func configurePageControl(){
        //Creamos el pageControl
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50 , width: UIScreen.main.bounds.width, height: 50))
        
        self.pageControl.numberOfPages = meals.count
        self.pageControl.currentPage = index
        self.pageControl.tintColor = UIColor.gray
        self.pageControl.pageIndicatorTintColor = UIColor.gray
        self.pageControl.currentPageIndicatorTintColor = UIColor.blue
       
        //Añadimos el elemento como subvista
        self.view.addSubview(pageControl)
        
    }
    
    
    func createViewController(pageNumber: Int, nombreComida: String, photo: UIImage, rating: Int ) -> UIViewController {
        //Instanciamos un ViewController
        let contentViewController = storyboard?.instantiateViewController(withIdentifier: "miComida") as! ViewController
        
        //Añadimos los datos de la comida en la posicion index al ViewController
        contentViewController.pageNumber  = pageNumber
        contentViewController.nombreComida = nombreComida
        contentViewController.foto = photo
        contentViewController.valor = rating
        
        //Añadimos el nombre de la comida a la barra de navegación
        navigationItem.title = nombreComida
        
        //Guardamos la página de la comida que estamos viendo en este momento y el índice
        vista = contentViewController
        index = pageNumber
        
        return contentViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //Añadimos el código para el paso de página a la izquierda calculando el módulo
        let page = mod(x: (viewController as! ViewController).pageNumber-meals.count-1,
                       m: numberOfPages)
        
    
        return createViewController(
            pageNumber: page, nombreComida: meals[page].name, photo:  meals[page].photo!, rating:  meals[page].rating)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //Añadimos el código para el paso de página a la derecha calculando el módulo
        let page = mod(x: (viewController as! ViewController).pageNumber+1 ,
                       m: numberOfPages)
       

        return createViewController(
            pageNumber: page, nombreComida: meals[page].name, photo: meals[page].photo!, rating: meals[page].rating)
    }
    
    func mod(x: Int, m: Int) -> Int{
        //Calculamos el módulo de la página
        let r = x % m
        return r < 0 ? r + m : r
    }
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // Coloreamos la página adecuada el pageControl

            self.pageControl.currentPage = index
        if primeraEjecucion < 3 {
            veces = veces + 1
        }else {
            primero = true
            veces = 0
        }
    }
    
    // MARK: - Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
            // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
            let isPresentingInAddMealMode = presentingViewController is UINavigationController
            
            if isPresentingInAddMealMode {
                dismiss(animated: true, completion: nil)
            }
            else {
                fatalError("The MealPageViewController is not inside a navigation controller.")
            }
    }
    
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        //Comprobamos si hemos pulsado el botón para guardar (Save)
        guard let button = sender as? UIBarButtonItem, button === save else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default,type: .debug)
            return
        }
        
        //Si hemos pulsado el botón guardar, asignamos los valores nuevos a la comida modificada
        let name = vista?.textField.text  ?? ""
        let foto = vista?.photo.image
        let rating = vista?.rating.rating
        
        meals[index].name = name
        meals[index].photo = foto
        meals[index].rating = rating!
        
        //Guardamos la comida
        saveMeals()
        
     }
    
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
}
