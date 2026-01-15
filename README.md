# CircAdmin 🎪

**CircAdmin** es una aplicación web **full‑stack** diseñada para resolver problemas reales de gestión y operación financiera en circos y espectáculos itinerantes. El objetivo del proyecto es **simplificar la administración diaria**, centralizando ingresos, egresos, localidades y usuarios en una sola plataforma.

Este proyecto fue desarrollado como producto real, enfrentando necesidades concretas de usuarios, lógica de negocio y decisiones técnicas similares a las de un SaaS en producción.

---

## 🚀 Problema que resuelve

La mayoría de los circos y espectáculos pequeños:

* No llevan control claro de ingresos y gastos
* Registran información en papel o planillas sueltas
* No tienen visibilidad por localidad o fecha
* Toman decisiones financieras sin datos claros

**CircAdmin** nace para:

* Centralizar la información financiera
* Automatizar registros de ingresos y egresos
* Entregar visibilidad clara por localidad y período
* Reducir errores manuales y carga operativa

---

## 🧩 Funcionalidades principales

* Autenticación de usuarios (Devise)
* Gestión de roles y permisos (dueño, administrador, contador)
* Registro de **ingresos y egresos**
* Asociación obligatoria de transacciones a **localidades**
* Resúmenes financieros diarios, semanales y mensuales
* Vistas tipo dashboard con datos reales
* Exportación de información
* Arquitectura preparada para escalar como SaaS

---

## 🛠️ Stack tecnológico

### Backend

* **Ruby on Rails**
* PostgreSQL
* Devise (autenticación)
* Cancancan (autorización)
* Pagy (paginación)
* AWS (Bucket S3)

### Frontend

* ERB + Turbo
* TailwindCSS
* Componentes reutilizables

### Infraestructura / Dev

* Git / GitHub
* Arquitectura MVC
* Código orientado a mantenibilidad

---

## 🧠 Enfoque técnico

* Desarrollo **end‑to‑end** (modelo → lógica → vista)
* Separación clara de responsabilidades
* Modelado de datos orientado a negocio real
* Decisiones técnicas priorizando claridad y escalabilidad
* Iteración constante según necesidades reales del producto

---

## 📸 Capturas / Demo

> Actualmente no hay demo pública activa.
> El foco del proyecto está en el **código, la arquitectura y la lógica de negocio**.

---

## 🏗️ Instalación local

```bash
# Clonar repositorio
git clone https://github.com/toffycaluga/circadmin.git
cd circadmin

# Instalar dependencias
bundle install

# Configurar base de datos
rails db:create db:migrate

# Levantar servidor
rails server
```

---

## 👨‍💻 Autor

**Abraham Lillo**
Full‑Stack Developer

* GitHub: [https://github.com/toffycaluga](https://github.com/toffycaluga)

---

## 📌 Nota

CircAdmin es un proyecto vivo, creado para resolver problemas reales y escalar hacia un producto SaaS. Se utiliza como base de aprendizaje, experimentación técnica y demostración de capacidades de desarrollo full‑stack orientado a producto.
