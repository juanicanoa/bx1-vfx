-- 1. Tabla de portadas
CREATE TABLE portadas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  categoria TEXT NOT NULL,
  descripcion TEXT,
  etiquetas TEXT[] DEFAULT '{}',
  tiene_contratapa BOOLEAN DEFAULT false,
  nombre_contratapa TEXT,
  imagen_url TEXT NOT NULL,
  imagen_contratapa_url TEXT,
  user_id UUID REFERENCES auth.users,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabla de admins (para controlar quién es admin)
CREATE TABLE admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL UNIQUE,
  email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Habilitar RLS (Row Level Security)
ALTER TABLE portadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- 4. Políticas de seguridad para portadas
-- Todos pueden ver las portadas
CREATE POLICY "Portadas son visibles a todos" 
ON portadas FOR SELECT USING (true);

-- Solo admins pueden insertar portadas
CREATE POLICY "Solo admins pueden insertar portadas" 
ON portadas FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM admins WHERE admins.user_id = auth.uid())
);

-- Solo admins pueden actualizar portadas
CREATE POLICY "Solo admins pueden actualizar portadas" 
ON portadas FOR UPDATE USING (
  EXISTS (SELECT 1 FROM admins WHERE admins.user_id = auth.uid())
);

-- Solo admins pueden eliminar portadas
CREATE POLICY "Solo admins pueden eliminar portadas" 
ON portadas FOR DELETE USING (
  EXISTS (SELECT 1 FROM admins WHERE admins.user_id = auth.uid())
);

-- 5. Políticas para la tabla de admins
-- Solo los propios usuarios pueden ver si son admin
CREATE POLICY "Usuarios pueden ver si son admin" 
ON admins FOR SELECT USING (auth.uid() = user_id);

-- Insertar el primer admin (cambia el email por el tuyo)
INSERT INTO auth.users (id, email, email_confirmed_at, aud, role)
VALUES (
  gen_random_uuid(),
  'tu-email@dominio.com',
  now(),
  'authenticated',
  'authenticated'
) ON CONFLICT (email) DO NOTHING;

-- Luego obtén el ID del usuario recién creado y úsalo aquí:
-- INSERT INTO admins (user_id, email) VALUES ('ID_DEL_USUARIO', 'tu-email@dominio.com');

-- 6. Crear bucket de almacenamiento
-- Ve a Storage en el dashboard de Supabase y crea un bucket llamado "bx1_images"
-- Configura las políticas para que solo admins puedan subir imágenes