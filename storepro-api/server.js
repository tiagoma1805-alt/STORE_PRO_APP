const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');

const app = express();
app.use(cors());
app.use(express.json());

const JWT_SECRET = "secreto_super_seguro_semana_5";

// Base de Datos Simulada en Memoria - Usuarios con Diferentes Roles
let usuarios = [
  { id: 1, email: "admin@storepro.com", password: "123456", nombre: "Administrador General", role: "admin" },
  { id: 2, email: "vendedor@storepro.com", password: "123456", nombre: "Carlos Vendedor", role: "vendedor" }
];

// Base de Datos Simulada - Categorías y Productos
let categorias = [  
  { id: 1, nombre: "Laptops", descripcion: "Equipos portátiles de alto rendimiento", estado: true },  
  { id: 2, nombre: "Smartphones", descripcion: "Móviles, telefonía y tablets", estado: true },
  { id: 3, nombre: "Audio & Sonido", descripcion: "Auriculares, altavoces y accesorios de audio", estado: true },
  { id: 4, nombre: "Accesorios & Periféricos", descripcion: "Teclados, mouses, monitores y más", estado: true },
  { id: 5, nombre: "Gaming", descripcion: "Consolas, mandos y accesorios para videojuegos", estado: true },
  { id: 6, nombre: "Wearables & Relojes", descripcion: "Smartwatches y bandas de actividad", estado: true }
];

let productos = [  
  { id: 101, nombre: "MacBook Pro M3", precio: 1999.99, stock: 10, categoriaId: 1, estado: true },  
  { id: 102, nombre: "iPhone 15 Pro", precio: 999.99, stock: 15, categoriaId: 2, estado: true },
  { id: 103, nombre: "Dell XPS 15", precio: 1499.50, stock: 8, categoriaId: 1, estado: true },  
  { id: 104, nombre: "Samsung Galaxy S24 Ultra", precio: 1199.00, stock: 12, categoriaId: 2, estado: true },
  { id: 105, nombre: "AirPods Pro 2", precio: 249.99, stock: 25, categoriaId: 3, estado: true },
  { id: 106, nombre: "Audífonos Sony WH-1000XM5", precio: 399.00, stock: 18, categoriaId: 3, estado: true },
  { id: 107, nombre: "Teclado Mecánico Logitech MX Keys", precio: 119.90, stock: 30, categoriaId: 4, estado: true },
  { id: 108, nombre: "Monitor Gamer LG UltraGear 27\"", precio: 349.99, stock: 7, categoriaId: 4, estado: true },
  { id: 109, nombre: "Mando Inalámbrico PS5 DualSense", precio: 69.99, stock: 20, categoriaId: 5, estado: true },
  { id: 110, nombre: "Consola Nintendo Switch OLED", precio: 349.00, stock: 14, categoriaId: 5, estado: true },
  { id: 111, nombre: "Apple Watch Series 9", precio: 429.00, stock: 9, categoriaId: 6, estado: true },
  { id: 112, nombre: "Mouse Inalámbrico Logitech MX Master 3S", precio: 99.99, stock: 22, categoriaId: 4, estado: false }
];

// Middleware para verificar la validez del Token JWT en cabeceras HTTP
function verificarToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ error: "Token no proporcionado" });

  const token = authHeader.split(' ')[1];
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: "Token inválido o expirado" });
    req.user = decoded;
    next();
  });
}

// ----------------------------------------------------
// 1. MÓDULO AUTENTICACIÓN Y PERFIL DE USUARIO
// ----------------------------------------------------
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = usuarios.find(u => u.email === email && u.password === password);

  if (user) {
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role, nombre: user.nombre },
      JWT_SECRET,
      { expiresIn: '8h' }
    );
    return res.json({ token, user: { id: user.id, email: user.email, nombre: user.nombre, role: user.role } });
  }
  return res.status(401).json({ error: "Credenciales inválidas" });
});

app.get('/api/auth/perfil', verificarToken, (req, res) => {
  const user = usuarios.find(u => u.id === req.user.id);
  if (user) {
    return res.json({ id: user.id, email: user.email, nombre: user.nombre, role: user.role });
  }
  return res.status(404).json({ error: "Usuario no encontrado" });
});

// ----------------------------------------------------
// 2. MÓDULO CATEGORÍAS - CRUD
// ----------------------------------------------------
app.get('/api/categorias', (req, res) => res.json(categorias));

app.get('/api/categorias/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const cat = categorias.find(c => c.id === id);
  if (cat) return res.json(cat);
  res.status(404).json({ error: "Categoría no encontrada" });
});

app.post('/api/categorias', verificarToken, (req, res) => {
  const nueva = { id: Date.now(), ...req.body, estado: true };
  categorias.push(nueva);
  res.status(201).json(nueva);
});

app.put('/api/categorias/:id', verificarToken, (req, res) => {
  const id = parseInt(req.params.id);
  const index = categorias.findIndex(c => c.id === id);
  if (index !== -1) {
    categorias[index] = { ...categorias[index], ...req.body };
    return res.json(categorias[index]);
  }
  res.status(404).json({ error: "Categoría no encontrada" });
});

app.patch('/api/categorias/:id/estado', verificarToken, (req, res) => {
  const id = parseInt(req.params.id);
  const cat = categorias.find(c => c.id === id);
  if (cat) {
    cat.estado = !cat.estado;
    return res.json(cat);
  }
  res.status(404).json({ error: "Categoría no encontrada" });
});

// ----------------------------------------------------
// 3. MÓDULO PRODUCTOS - CRUD
// ----------------------------------------------------
app.get('/api/productos', (req, res) => {
  const respuesta = productos.map(p => ({
    ...p,
    categoria: categorias.find(c => c.id === p.categoriaId)
  }));
  res.json(respuesta);
});

app.get('/api/productos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const prod = productos.find(p => p.id === id);
  if (prod) {
    const respuesta = {
      ...prod,
      categoria: categorias.find(c => c.id === prod.categoriaId)
    };
    return res.json(respuesta);
  }
  res.status(404).json({ error: "Producto no encontrado" });
});

app.post('/api/productos', verificarToken, (req, res) => {
  const nuevo = { id: Date.now(), ...req.body, estado: true };
  productos.push(nuevo);
  res.status(201).json(nuevo);
});

app.put('/api/productos/:id', verificarToken, (req, res) => {
  const id = parseInt(req.params.id);
  const index = productos.findIndex(p => p.id === id);
  if (index !== -1) {
    productos[index] = { ...productos[index], ...req.body };
    return res.json(productos[index]);
  }
  res.status(404).json({ error: "Producto no encontrado" });
});

app.patch('/api/productos/:id/estado', verificarToken, (req, res) => {
  const id = parseInt(req.params.id);
  const prod = productos.find(p => p.id === id);
  if (prod) {
    prod.estado = !prod.estado;
    return res.json(prod);
  }
  res.status(404).json({ error: "Producto no encontrado" });
});

app.listen(3000, '0.0.0.0', () => console.log("Servidor StorePro corriendo en http://0.0.0.0:3000"));
