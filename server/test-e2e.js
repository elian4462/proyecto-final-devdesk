// Prueba automatizada End-to-End del servidor DevDesk
// Ejecución: node test-e2e.js
const http = require('http');

const BASE_URL = 'http://localhost:3000';

function peticion(metodo, ruta, datos = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(ruta, BASE_URL);
    const cabeceras = { 'Content-Type': 'application/json' };
    if (token) cabeceras['Authorization'] = `Bearer ${token}`;

    const req = http.request(
      url,
      {
        method: metodo,
        headers: cabeceras,
      },
      (res) => {
        let cuerpo = '';
        res.on('data', (c) => (cuerpo += c));
        res.on('end', () => {
          let data = null;
          if (cuerpo) {
            try {
              data = JSON.parse(cuerpo);
            } catch (_) {
              data = cuerpo;
            }
          }
          resolve({ status: res.statusCode, headers: res.headers, data });
        });
      }
    );

    req.on('error', reject);
    if (datos) req.write(JSON.stringify(datos));
    req.end();
  });
}

async function correrPruebas() {
  console.log('🚀 Iniciando pruebas E2E sobre el backend DevDesk...');

  try {
    // 1. Activos de infraestructura
    const rActivos = await peticion('GET', '/activos/');
    console.log(`[1] GET /activos/ -> Status ${rActivos.status}`);
    if (rActivos.status !== 200 || !Array.isArray(rActivos.data) || rActivos.data.length < 20) {
      throw new Error(`Se esperaban al menos 20 activos, se obtuvieron: ${rActivos.data?.length}`);
    }
    console.log(`    ✅ 20 activos TI verificados correctamente.`);

    // 2. Login
    const rLogin = await peticion('POST', '/usuarios/token', {
      username: 'admin@empresa.com',
      password: 'admin-1234',
    });
    console.log(`[2] POST /usuarios/token -> Status ${rLogin.status}`);
    if (rLogin.status !== 200 || !rLogin.data.access_token) {
      throw new Error('No se recibió token de acceso');
    }
    const token = rLogin.data.access_token;
    console.log(`    ✅ Token de acceso JWT generado.`);

    // 3. Usuario actual
    const rMe = await peticion('GET', '/usuarios/me', null, token);
    console.log(`[3] GET /usuarios/me -> Status ${rMe.status}`);
    if (rMe.status !== 200 || rMe.data.email !== 'admin@empresa.com') {
      throw new Error('Fallo al obtener datos del usuario autenticado');
    }
    console.log(`    ✅ Usuario autenticado: ${rMe.data.email}`);

    // 4. Crear Ticket
    const rCrear = await peticion(
      'POST',
      '/tickets/',
      {
        titulo: 'Prueba E2E Servidor',
        descripcion: 'Verificación de pipeline de soporte',
        categoria: 'servidores',
        prioridad: 'alta',
        equipo_afectado: 'SRV-WEB-01',
      },
      token
    );
    console.log(`[4] POST /tickets/ -> Status ${rCrear.status}`);
    if (rCrear.status !== 201 || !rCrear.data.id) {
      throw new Error('No se pudo crear el ticket');
    }
    const idTicket = rCrear.data.id;
    console.log(`    ✅ Ticket #${idTicket} creado exitosamente.`);

    // 5. Actualizar Ticket
    const rUpdate = await peticion('PATCH', `/tickets/${idTicket}`, { estado: 'resuelto' }, token);
    console.log(`[5] PATCH /tickets/${idTicket} -> Status ${rUpdate.status}`);
    if (rUpdate.status !== 200 || rUpdate.data.estado !== 'resuelto') {
      throw new Error('No se actualizó el estado del ticket');
    }
    console.log(`    ✅ Ticket #${idTicket} marcado como resuelto.`);

    // 6. Eliminar Ticket
    const rDelete = await peticion('DELETE', `/tickets/${idTicket}`, null, token);
    console.log(`[6] DELETE /tickets/${idTicket} -> Status ${rDelete.status}`);
    if (rDelete.status !== 204) {
      throw new Error('No se eliminó el ticket');
    }
    console.log(`    ✅ Ticket #${idTicket} eliminado.`);

    // 7. Asistente IA
    const rChat = await peticion('POST', '/api/chat', {
      mensaje: 'El servidor web tiene alta latencia de CPU',
    });
    console.log(`[7] POST /api/chat -> Status ${rChat.status}`);
    if (rChat.status !== 200 || !rChat.data.respuesta) {
      throw new Error('No se recibió respuesta del asistente de IA');
    }
    console.log(`    ✅ Asistente IA respondió con diagnóstico técnico.`);

    console.log('\n🎉 ¡TODAS LAS PRUEBAS E2E PASARON EXITOSAMENTE!');
  } catch (error) {
    console.error('\n❌ Error en prueba E2E:', error.message);
    process.exit(1);
  }
}

correrPruebas();
