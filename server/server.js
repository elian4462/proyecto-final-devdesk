// Server DevDesk Backend — HTTP REST & AI Proxy
// Ejecutar con: node server.js
const http = require('http');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const PUERTO = process.env.PORT || 3000;
const DB_PATH = path.join(__dirname, 'db.json');

// Base de datos inicial en memoria con persistencia en archivo
const DB_INICIAL = {
  usuarios: [
    {
      id: 1,
      email: 'admin@empresa.com',
      passwordHash: crypto.createHash('sha256').update('admin-1234').digest('hex'),
      nombre: 'Administrador TI',
      rol: 'admin',
    },
    {
      id: 2,
      email: 'tecnico@empresa.com',
      passwordHash: crypto.createHash('sha256').update('tecnico-1234').digest('hex'),
      nombre: 'Carlos Mendoza',
      rol: 'tecnico',
    },
  ],
  tickets: [
    {
      id: 1,
      titulo: 'Saturación de memoria en nodo Kubernetes Worker 01',
      descripcion: 'El nodo SRV-K8S-WORKER01 reporta 89% de uso sostenido de CPU y 86% de RAM.',
      categoria: 'servidores',
      prioridad: 'alta',
      estado: 'abierto',
      equipo_afectado: 'SRV-K8S-WORKER01',
      fecha: '2026-10-27',
      solucion: null,
    },
    {
      id: 2,
      titulo: 'Actualización programada de firmware en firewall',
      descripcion: 'Aplicación de parche de seguridad FortiOS 7.4.2 en ventana nocturna.',
      categoria: 'seguridad',
      prioridad: 'media',
      estado: 'en_progreso',
      equipo_afectado: 'FW-CORE-FORTINET',
      fecha: '2026-10-27',
      solucion: null,
    },
    {
      id: 3,
      titulo: 'Reemplazo de baterías en UPS Datacenter',
      descripcion: 'Mantenimiento preventivo en módulo de respaldo APC Smart-UPS 3000.',
      categoria: 'hardware',
      prioridad: 'baja',
      estado: 'resuelto',
      equipo_afectado: 'UPS-APC-SMART3000',
      fecha: '2026-10-26',
      solucion: 'Baterías reemplazadas y calibradas exitosamente.',
    },
  ],
  activos: [
    { id: 1, nombre: 'SRV-WEB-01', tipo: 'Servidor', ip: '192.168.10.15', sistema_operativo: 'Linux Ubuntu 22.04 LTS', estado: 'Operativo', ubicacion: 'Datacenter Quito (Rack A1)', cpu_uso: 32.5, memoria_uso: 48.0, descripcion: 'Servidor web frontend en producción con Nginx y balanceador de carga.' },
    { id: 2, nombre: 'SRV-DB-PRIMARY', tipo: 'Base de Datos', ip: '192.168.10.20', sistema_operativo: 'Linux Debian 12', estado: 'Operativo', ubicacion: 'Datacenter Quito (Rack A2)', cpu_uso: 64.2, memoria_uso: 82.1, descripcion: 'Cluster PostgreSQL principal de alta disponibilidad con streaming replication.' },
    { id: 3, nombre: 'SRV-DB-REPLICA', tipo: 'Base de Datos', ip: '192.168.20.20', sistema_operativo: 'Linux Debian 12', estado: 'Operativo', ubicacion: 'Datacenter Guayaquil (Rack B1)', cpu_uso: 28.0, memoria_uso: 61.4, descripcion: 'Réplica de solo lectura para reportes y contingencia de base de datos.' },
    { id: 4, nombre: 'FW-CORE-FORTINET', tipo: 'Seguridad', ip: '192.168.1.1', sistema_operativo: 'FortiOS 7.4', estado: 'Operativo', ubicacion: 'Sede Central (Rack Core)', cpu_uso: 45.0, memoria_uso: 52.3, descripcion: 'Firewall perimetral FortiGate 100F con inspección SSL y filtrado UTM.' },
    { id: 5, nombre: 'SW-CORE-CISCO', tipo: 'Redes', ip: '192.168.1.2', sistema_operativo: 'Cisco IOS-XE 17.9', estado: 'Operativo', ubicacion: 'Datacenter Quito (Rack Core)', cpu_uso: 18.5, memoria_uso: 35.0, descripcion: 'Switch Core Catalyst 9300 48P PoE+ con enlaces 10G hacia distribución.' },
    { id: 6, nombre: 'SRV-K8S-MASTER01', tipo: 'Servidor', ip: '10.0.1.10', sistema_operativo: 'Linux Ubuntu 22.04 LTS', estado: 'Operativo', ubicacion: 'AWS us-east-1 VPC-Prod', cpu_uso: 55.4, memoria_uso: 71.0, descripcion: 'Plano de control Kubernetes (API Server, etcd, controller manager).' },
    { id: 7, nombre: 'SRV-K8S-WORKER01', tipo: 'Servidor', ip: '10.0.1.11', sistema_operativo: 'Linux Ubuntu 22.04 LTS', estado: 'Alerta', ubicacion: 'AWS us-east-1 VPC-Prod', cpu_uso: 89.2, memoria_uso: 86.5, descripcion: 'Nodo worker de microservicios con sobrecarga temporal en contenedores.' },
    { id: 8, nombre: 'SRV-K8S-WORKER02', tipo: 'Servidor', ip: '10.0.1.12', sistema_operativo: 'Linux Ubuntu 22.04 LTS', estado: 'Operativo', ubicacion: 'AWS us-east-1 VPC-Prod', cpu_uso: 41.0, memoria_uso: 58.2, descripcion: 'Nodo worker secundario para distribución de carga y pods de backend.' },
    { id: 9, nombre: 'SRV-AUTH-LDAP', tipo: 'Seguridad', ip: '192.168.10.5', sistema_operativo: 'Windows Server 2022', estado: 'Operativo', ubicacion: 'Datacenter Quito (Rack A1)', cpu_uso: 22.0, memoria_uso: 45.7, descripcion: 'Controlador de dominio Active Directory y servicio de autenticación corporativa.' },
    { id: 10, nombre: 'NAS-STORAGE-BACKUP', tipo: 'Almacenamiento', ip: '192.168.20.50', sistema_operativo: 'Synology DSM 7.2', estado: 'Operativo', ubicacion: 'Datacenter Guayaquil (Rack B2)', cpu_uso: 38.0, memoria_uso: 54.0, descripcion: 'Almacenamiento RAID 6 de 96TB para respaldos nocturnos cifrados.' },
    { id: 11, nombre: 'SRV-MAIL-EXCHANGE', tipo: 'Servidor', ip: '192.168.10.30', sistema_operativo: 'Windows Server 2022', estado: 'Mantenimiento', ubicacion: 'Datacenter Quito (Rack A3)', cpu_uso: 12.0, memoria_uso: 40.0, descripcion: 'Servidor de mensajería empresarial en ventana de actualización de seguridad.' },
    { id: 12, nombre: 'AP-WIFI-PISO2', tipo: 'Redes', ip: '192.168.5.12', sistema_operativo: 'ArubaOS 8.10', estado: 'Operativo', ubicacion: 'Edificio Central Piso 2', cpu_uso: 15.0, memoria_uso: 29.0, descripcion: 'Punto de acceso WiFi 6 empresarial con soporte para 120 dispositivos.' },
    { id: 13, nombre: 'AP-WIFI-PISO3', tipo: 'Redes', ip: '192.168.5.13', sistema_operativo: 'ArubaOS 8.10', estado: 'Operativo', ubicacion: 'Edificio Central Piso 3', cpu_uso: 17.5, memoria_uso: 31.0, descripcion: 'Punto de acceso WiFi 6 para área de desarrollo y salas de reuniones.' },
    { id: 14, nombre: 'SRV-VPN-GATEWAY', tipo: 'Seguridad', ip: '192.168.0.10', sistema_operativo: 'Linux Alpine 3.19', estado: 'Operativo', ubicacion: 'DMZ Datacenter Quito', cpu_uso: 36.8, memoria_uso: 44.1, descripcion: 'Servidor WireGuard y OpenVPN con autenticación 2FA para trabajo remoto.' },
    { id: 15, nombre: 'SRV-MONITOR-ZABBIX', tipo: 'Servidor', ip: '192.168.10.80', sistema_operativo: 'Linux Ubuntu 22.04 LTS', estado: 'Operativo', ubicacion: 'Datacenter Quito (Rack A4)', cpu_uso: 49.3, memoria_uso: 66.8, descripcion: 'Plataforma de monitoreo SNMP/Agentes Zabbix y tableros Grafana en tiempo real.' },
    { id: 16, nombre: 'SRV-CI-GITLAB', tipo: 'Servidor', ip: '10.2.0.15', sistema_operativo: 'Linux Debian 12', estado: 'Operativo', ubicacion: 'Azure East US VNet', cpu_uso: 60.1, memoria_uso: 75.0, descripcion: 'Instancia GitLab Server dedicada con Docker runners para pipelines CI/CD.' },
    { id: 17, nombre: 'SRV-PROXY-CLOUDFLARE', tipo: 'Redes', ip: '192.168.10.12', sistema_operativo: 'Linux Debian 12', estado: 'Operativo', ubicacion: 'DMZ Datacenter Quito', cpu_uso: 25.4, memoria_uso: 38.0, descripcion: 'Proxy inverso con certificados TLS automatizados y protección DoS.' },
    { id: 18, nombre: 'UPS-APC-SMART3000', tipo: 'Hardware', ip: '192.168.10.250', sistema_operativo: 'Firmware APC v4.2', estado: 'Operativo', ubicacion: 'Datacenter Quito (Base Rack)', cpu_uso: 8.0, memoria_uso: 14.0, descripcion: 'Sistema de alimentación ininterrumpida 3000VA con tarjeta SNMP de gestión.' },
    { id: 19, nombre: 'RTR-EDGE-MIKROTIK', tipo: 'Redes', ip: '192.168.1.254', sistema_operativo: 'RouterOS v7.12', estado: 'Operativo', ubicacion: 'Sede Central (Rack Telecom)', cpu_uso: 33.0, memoria_uso: 47.0, descripcion: 'Enrutador BGP con doble proveedor de internet fibra óptica en failover.' },
    { id: 20, nombre: 'SRV-REDIS-CACHE', tipo: 'Base de Datos', ip: '192.168.10.25', sistema_operativo: 'Linux Alpine 3.19', estado: 'Operativo', ubicacion: 'Datacenter Quito (Rack A2)', cpu_uso: 19.5, memoria_uso: 58.9, descripcion: 'Instancia Redis en memoria para almacenamiento de sesiones web y caché.' },
  ],
};

let db = DB_INICIAL;
if (fs.existsSync(DB_PATH)) {
  try {
    db = JSON.parse(fs.readFileSync(DB_PATH, 'utf-8'));
  } catch (_) {}
}

function guardarDb() {
  try {
    fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2), 'utf-8');
  } catch (_) {}
}

function responderJson(res, codigo, datos, cabeceras = {}) {
  res.writeHead(codigo, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    ...cabeceras,
  });
  res.end(datos !== null && datos !== undefined ? JSON.stringify(datos) : '');
}

function generarToken(usuario) {
  const payload = Buffer.from(JSON.stringify({ id: usuario.id, email: usuario.email, exp: Date.now() + 86400000 })).toString('base64');
  return `eyJhbGciOiJIUzI1NiJ9.${payload}.firmaDevDesk`;
}

function verificarToken(req) {
  const auth = req.headers['authorization'];
  if (!auth || !auth.startsWith('Bearer ')) return null;
  const token = auth.substring(7);
  const partes = token.split('.');
  if (partes.length < 2) return null;
  try {
    const payload = JSON.parse(Buffer.from(partes[1], 'base64').toString('utf-8'));
    return db.usuarios.find((u) => u.id === payload.id) || null;
  } catch (_) {
    return null;
  }
}

const servidor = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    return res.end();
  }

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const ruta = url.pathname;

  // Leer cuerpo si existe
  let cuerpoTexto = '';
  for await (const chunk of req) cuerpoTexto += chunk;
  let body = {};
  if (cuerpoTexto) {
    try {
      body = JSON.parse(cuerpoTexto);
    } catch (_) {
      // Manejar application/x-www-form-urlencoded
      try {
        body = Object.fromEntries(new URLSearchParams(cuerpoTexto));
      } catch (_) {}
    }
  }

  // Rutas de Usuario y Autenticación
  if (ruta === '/usuarios/' && req.method === 'POST') {
    const { email, password, nombre } = body;
    if (!email || !password) {
      return responderJson(res, 400, { detail: 'Email y contraseña requeridos' });
    }
    if (db.usuarios.some((u) => u.email === email)) {
      return responderJson(res, 400, { detail: `El correo ${email} ya está registrado` });
    }
    const nuevo = {
      id: db.usuarios.length + 1,
      email,
      passwordHash: crypto.createHash('sha256').update(password).digest('hex'),
      nombre: nombre || 'Técnico TI',
      rol: 'tecnico',
    };
    db.usuarios.push(nuevo);
    guardarDb();
    return responderJson(res, 201, { id: nuevo.id, email: nuevo.email, nombre: nuevo.nombre, rol: nuevo.rol });
  }

  if (ruta === '/usuarios/token' && req.method === 'POST') {
    const email = body.username || body.email;
    const password = body.password;
    const user = db.usuarios.find((u) => u.email === email);
    const passHash = password ? crypto.createHash('sha256').update(password).digest('hex') : '';
    if (!user || user.passwordHash !== passHash) {
      return responderJson(res, 401, { detail: 'Credenciales incorrectas' });
    }
    return responderJson(res, 200, { access_token: generarToken(user), token_type: 'bearer' });
  }

  if (ruta === '/usuarios/me' && req.method === 'GET') {
    const usuario = verificarToken(req);
    if (!usuario) {
      return responderJson(res, 401, { detail: 'Tu sesión caducó, inicia sesión de nuevo.' });
    }
    return responderJson(res, 200, { id: usuario.id, email: usuario.email, nombre: usuario.nombre, rol: usuario.rol });
  }

  if (ruta === '/usuarios/password' && req.method === 'PATCH') {
    const usuario = verificarToken(req);
    if (!usuario) {
      return responderJson(res, 401, { detail: 'No autenticado' });
    }
    const { password_actual, password_nueva } = body;
    const actualHash = crypto.createHash('sha256').update(password_actual || '').digest('hex');
    if (usuario.passwordHash !== actualHash) {
      return responderJson(res, 400, { detail: 'La contraseña actual no es correcta' });
    }
    usuario.passwordHash = crypto.createHash('sha256').update(password_nueva).digest('hex');
    guardarDb();
    return responderJson(res, 200, { mensaje: 'Contraseña actualizada' });
  }

  // Rutas de Activos de Infraestructura
  if (ruta === '/activos/' && req.method === 'GET') {
    return responderJson(res, 200, db.activos);
  }

  // Rutas de Tickets (CRUD protegido por autenticación)
  if (ruta === '/tickets/' && req.method === 'GET') {
    const usuario = verificarToken(req);
    if (!usuario) {
      return responderJson(res, 401, { detail: 'Tu sesión caducó o no estás autenticado.' });
    }
    return responderJson(res, 200, db.tickets, { 'x-total-count': `${db.tickets.length}` });
  }

  if (ruta === '/tickets/' && req.method === 'POST') {
    const usuario = verificarToken(req);
    if (!usuario) {
      return responderJson(res, 401, { detail: 'Tu sesión caducó o no estás autenticado.' });
    }
    const { titulo, descripcion, categoria, prioridad, equipo_afectado } = body;
    if (!titulo || !descripcion) {
      return responderJson(res, 422, { detail: 'Título y descripción son requeridos' });
    }
    const maxId = db.tickets.reduce((max, t) => Math.max(max, t.id), 0);
    const nuevo = {
      id: maxId + 1,
      titulo,
      descripcion,
      categoria: categoria || 'servidores',
      prioridad: prioridad || 'media',
      estado: 'abierto',
      equipo_afectado: equipo_afectado || 'General',
      fecha: new Date().toISOString().substring(0, 10),
      solucion: null,
    };
    db.tickets.unshift(nuevo);
    guardarDb();
    return responderJson(res, 201, nuevo);
  }

  const matchTicket = ruta.match(/^\/tickets\/(\d+)$/);
  if (matchTicket) {
    const usuario = verificarToken(req);
    if (!usuario) {
      return responderJson(res, 401, { detail: 'Tu sesión caducó o no estás autenticado.' });
    }
    const id = parseInt(matchTicket[1], 10);
    const idx = db.tickets.findIndex((t) => t.id === id);
    if (idx === -1) {
      return responderJson(res, 404, { detail: `El ticket #${id} no existe.` });
    }

    if (req.method === 'PATCH') {
      db.tickets[idx] = { ...db.tickets[idx], ...body };
      guardarDb();
      return responderJson(res, 200, db.tickets[idx]);
    }

    if (req.method === 'DELETE') {
      db.tickets.splice(idx, 1);
      guardarDb();
      return responderJson(res, 204, null);
    }
  }

  // Asistente IA (POST /api/chat)
  if (ruta === '/api/chat' && req.method === 'POST') {
    const mensaje = body.mensaje || '';
    const lower = mensaje.toLowerCase();

    // Diagnóstico inteligente contextual para soporte de infraestructura
    let respuesta = 'Hola, como asistente técnico DevDesk puedo ayudarte con diagnósticos de red, servidores y gestión de tickets.';
    let accion = null;

    if (lower.includes('cpu') || lower.includes('carga') || lower.includes('rendimiento')) {
      respuesta = 'Diagnóstico para sobrecarga de CPU:\n' +
        '1. Ejecuta `top -b -n 1 | head -n 20` para verificar procesos consumidores.\n' +
        '2. Comprueba si hay hilos bloqueados en disco (iowait) con `vmstat 1 5`.\n' +
        '3. Revisa la asignación de cuotas de CPU en contenedores si es un nodo Kubernetes.';
      accion = {
        nombre: 'crear_ticket',
        argumentos: {
          titulo: 'Alerta de sobrecarga de CPU en servidor',
          descripcion: 'Consumo excesivo de recursos identificado durante monitoreo.',
          categoria: 'servidores',
          prioridad: 'alta',
          equipo_afectado: 'SRV-K8S-WORKER01',
        },
      };
    } else if (lower.includes('red') || lower.includes('vpn') || lower.includes('ping') || lower.includes('enlace')) {
      respuesta = 'Diagnóstico para enlace de red / VPN:\n' +
        '1. Verifica MTU en la interfaz con `ip link show dev wg0`.\n' +
        '2. Comprueba resolución DNS y handshake con `wg show`.\n' +
        '3. Inspecciona logs perimetrales en el firewall Fortinet.';
      accion = {
        nombre: 'crear_ticket',
        argumentos: {
          titulo: 'Pérdida de paquetes en enlace o túnel VPN',
          descripcion: 'Falla intermitente en túnel de comunicación segura.',
          categoria: 'redes',
          prioridad: 'alta',
          equipo_afectado: 'SRV-VPN-GATEWAY',
        },
      };
    } else if (lower.includes('postgres') || lower.includes('base de datos') || lower.includes('sql')) {
      respuesta = 'Diagnóstico de base de datos PostgreSQL:\n' +
        '1. Analiza consultas activas con `SELECT pid, state, query FROM pg_stat_activity WHERE state != \'idle\';`.\n' +
        '2. Verifica la relación de réplica con `SELECT * FROM pg_stat_replication;`.\n' +
        '3. Comprueba autovacuum y bloating en tablas principales.';
      accion = {
        nombre: 'crear_ticket',
        argumentos: {
          titulo: 'Optimización de consultas en cluster PostgreSQL',
          descripcion: 'Lentitud y tiempo de respuesta elevado en base de datos.',
          categoria: 'servidores',
          prioridad: 'media',
          equipo_afectado: 'SRV-DB-PRIMARY',
        },
      };
    }

    return responderJson(res, 200, {
      respuesta,
      accion,
    });
  }

  return responderJson(res, 404, { detail: `Ruta no encontrada: ${req.method} ${ruta}` });
});

servidor.listen(PUERTO, () => {
  console.log(`[DevDesk Backend] Servidor activo escuchando en http://localhost:${PUERTO}`);
  console.log(`[DevDesk Backend] Endpoints disponibles:`);
  console.log(`  - POST /usuarios/`);
  console.log(`  - POST /usuarios/token`);
  console.log(`  - GET  /usuarios/me`);
  console.log(`  - GET  /activos/`);
  console.log(`  - GET, POST /tickets/`);
  console.log(`  - PATCH, DELETE /tickets/:id`);
  console.log(`  - POST /api/chat`);
});
