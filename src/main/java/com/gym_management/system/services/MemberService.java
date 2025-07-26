package com.gym_management.system.services;

import com.gym_management.system.model.dto.CreateMemberRequest;
import com.gym_management.system.model.dto.MemberResponse;
import com.gym_management.system.model.dto.UpdateMemberRequest;
import org.springframework.data.domain.Page;

import java.util.List;

/**
 * Interfaz de servicio para la gestión de miembros del gimnasio.
 * 
 * <p>Esta interfaz define los contratos para todas las operaciones de negocio 
 * relacionadas con la gestión de miembros del gimnasio, incluyendo operaciones 
 * CRUD (Create, Read, Update, Delete), búsquedas y estadísticas.</p>
 * 
 * <p><strong>Características principales:</strong></p>
 * <ul>
 *   <li>Gestión completa del ciclo de vida de miembros</li>
 *   <li>Validaciones de negocio integradas</li>
 *   <li>Soporte para paginación y ordenamiento</li>
 *   <li>Búsquedas flexibles por múltiples criterios</li>
 *   <li>Borrado lógico (soft delete) para auditoría</li>
 * </ul>
 * 
 * <p><strong>Ejemplo de uso:</strong></p>
 * <pre>{@code
 * @Autowired
 * private MemberService memberService;
 * 
 * // Crear un nuevo miembro
 * CreateMemberRequest request = new CreateMemberRequest();
 * request.setFirstName("Juan");
 * request.setLastName("Pérez");
 * request.setEmail("juan.perez@email.com");
 * MemberResponse member = memberService.createMember(request);
 * 
 * // Buscar miembros activos
 * List<MemberResponse> activeMembers = memberService.getActiveMembers();
 * }</pre>
 * 
 * @author Equipo de Desarrollo Gym Management
 * @version 1.0
 * @since 1.0
 * @see MemberResponse
 * @see CreateMemberRequest
 * @see UpdateMemberRequest
 */
public interface MemberService {

    /**
     * Crea un nuevo miembro en el sistema del gimnasio.
     * 
     * <p>Este método valida que el email sea único en el sistema antes de crear 
     * el miembro. Si el email ya existe, se lanza una excepción.</p>
     * 
     * <p><strong>Validaciones realizadas:</strong></p>
     * <ul>
     *   <li>Email único en el sistema</li>
     *   <li>Formato válido de email</li>
     *   <li>Campos obligatorios presentes</li>
     *   <li>Rangos válidos para altura y peso</li>
     * </ul>
     * 
     * <p><strong>Ejemplo de uso:</strong></p>
     * <pre>{@code
     * CreateMemberRequest request = new CreateMemberRequest();
     * request.setFirstName("Ana");
     * request.setLastName("García");
     * request.setEmail("ana.garcia@email.com");
     * request.setPhone("+56987654321");
     * request.setBirthDate(LocalDate.of(1990, 5, 15));
     * request.setGender("F");
     * 
     * MemberResponse newMember = memberService.createMember(request);
     * System.out.println("Miembro creado con ID: " + newMember.getId());
     * }</pre>
     *
     * @param request Objeto DTO que contiene todos los datos necesarios para crear el miembro.
     *                Debe incluir nombre, apellido, email, teléfono, fecha de nacimiento y género.
     *                Los campos altura, peso, contacto de emergencia y observaciones son opcionales.
     * @return {@link MemberResponse} Información completa del miembro recién creado, incluyendo
     *         el ID generado automáticamente, timestamps de creación y campos calculados como edad.
     * @throws com.gym_management.system.exception.DuplicateEmailException 
     *         Si ya existe un miembro registrado con el mismo email.
     * @see CreateMemberRequest
     * @see MemberResponse
     * @since 1.0
     */
    MemberResponse createMember(CreateMemberRequest request);

    /**
     * Obtiene todos los miembros del sistema con soporte para paginación y ordenamiento.
     * 
     * <p>Este método permite recuperar miembros de forma paginada para optimizar el rendimiento
     * cuando hay grandes volúmenes de datos. Soporta ordenamiento por cualquier campo válido.</p>
     * 
     * <p><strong>Campos de ordenamiento soportados:</strong></p>
     * <ul>
     *   <li>{@code firstName} - Nombre</li>
     *   <li>{@code lastName} - Apellido</li>
     *   <li>{@code email} - Email</li>
     *   <li>{@code createdAt} - Fecha de creación</li>
     *   <li>{@code updatedAt} - Fecha de actualización</li>
     * </ul>
     * 
     * <p><strong>Ejemplo de uso:</strong></p>
     * <pre>{@code
     * // Obtener primera página (10 elementos) ordenados por apellido
     * Page<MemberResponse> page = memberService.getAllMembers(0, 10, "lastName", "asc");
     * 
     * System.out.println("Total de miembros: " + page.getTotalElements());
     * System.out.println("Páginas totales: " + page.getTotalPages());
     * 
     * for (MemberResponse member : page.getContent()) {
     *     System.out.println(member.getFullName());
     * }
     * }</pre>
     *
     * @param page Número de página a recuperar (base 0). Debe ser mayor o igual a 0.
     * @param size Cantidad de elementos por página. Recomendado entre 5 y 100.
     * @param sortBy Campo por el cual ordenar los resultados. Debe ser un campo válido de la entidad Member.
     * @param sortDirection Dirección del ordenamiento: "asc" para ascendente, "desc" para descendente.
     * @return {@link Page}&lt;{@link MemberResponse}&gt; Página con los miembros encontrados, 
     *         incluyendo metadatos de paginación como total de elementos y páginas.
     * @throws org.springframework.data.mapping.PropertyReferenceException 
     *         Si el campo de ordenamiento especificado no existe.
     * @see MemberResponse
     * @see org.springframework.data.domain.Page
     * @since 1.0
     */
    Page<MemberResponse> getAllMembers(int page, int size, String sortBy, String sortDirection);

    /**
     * Obtiene un miembro específico por su identificador único.
     * 
     * <p>Este método busca un miembro por su ID en la base de datos. El ID debe 
     * corresponder a un miembro existente, caso contrario se lanza una excepción.</p>
     * 
     * <p><strong>Ejemplo de uso:</strong></p>
     * <pre>{@code
     * try {
     *     MemberResponse member = memberService.getMemberById(1L);
     *     System.out.println("Miembro encontrado: " + member.getFullName());
     *     System.out.println("Email: " + member.getEmail());
     *     System.out.println("Estado: " + (member.getIsActive() ? "Activo" : "Inactivo"));
     * } catch (MemberNotFoundException e) {
     *     System.err.println("Miembro no encontrado: " + e.getMessage());
     * }
     * }</pre>
     *
     * @param id Identificador único del miembro a buscar. Debe ser un número positivo.
     * @return {@link MemberResponse} Información completa del miembro encontrado, incluyendo
     *         datos personales, información de contacto, datos físicos y timestamps.
     * @throws com.gym_management.system.exception.MemberNotFoundException 
     *         Si no existe un miembro con el ID especificado.
     * @throws IllegalArgumentException Si el ID es null o menor a 1.
     * @see MemberResponse
     * @since 1.0
     */
    MemberResponse getMemberById(Long id);

    /**
     * Obtiene un miembro específico por su dirección de email.
     * 
     * <p>Este método busca un miembro utilizando su email como criterio de búsqueda.
     * Como los emails son únicos en el sistema, este método retorna exactamente 
     * un miembro o lanza una excepción si no se encuentra.</p>
     * 
     * <p><strong>Casos de uso típicos:</strong></p>
     * <ul>
     *   <li>Login/autenticación de miembros</li>
     *   <li>Verificación de existencia antes de registro</li>
     *   <li>Recuperación de datos por email en formularios</li>
     * </ul>
     * 
     * <p><strong>Ejemplo de uso:</strong></p>
     * <pre>{@code
     * String emailBuscado = "juan.perez@email.com";
     * 
     * try {
     *     MemberResponse member = memberService.getMemberByEmail(emailBuscado);
     *     System.out.println("Miembro encontrado: " + member.getFullName());
     *     
     *     if (!member.getIsActive()) {
     *         System.out.println("⚠️ Atención: El miembro está inactivo");
     *     }
     * } catch (MemberNotFoundException e) {
     *     System.out.println("No existe miembro con email: " + emailBuscado);
     * }
     * }</pre>
     *
     * @param email Dirección de email del miembro a buscar. Debe tener formato válido de email.
     * @return {@link MemberResponse} Información completa del miembro que tiene el email especificado.
     * @throws com.gym_management.system.exception.MemberNotFoundException 
     *         Si no existe un miembro registrado con el email especificado.
     * @throws IllegalArgumentException Si el email es null, vacío o tiene formato inválido.
     * @see MemberResponse
     * @since 1.0
     */
    MemberResponse getMemberByEmail(String email);

    /**
     * Actualiza la información de un miembro existente en el sistema.
     * 
     * <p>Este método permite actualizar parcialmente los datos de un miembro.
     * Solo los campos no nulos en el objeto request serán actualizados, 
     * manteniendo los valores existentes para los campos omitidos.</p>
     * 
     * <p><strong>Validaciones realizadas:</strong></p>
     * <ul>
     *   <li>El miembro debe existir en el sistema</li>
     *   <li>Si se cambia el email, debe ser único</li>
     *   <li>Validaciones de formato para campos modificados</li>
     *   <li>Rangos válidos para campos numéricos</li>
     * </ul>
     * 
     * <p><strong>Ejemplo de actualización parcial:</strong></p>
     * <pre>{@code
     * // Solo actualizar teléfono y peso
     * UpdateMemberRequest updateRequest = new UpdateMemberRequest();
     * updateRequest.setPhone("+56912345678");
     * updateRequest.setWeight(72.5);
     * 
     * try {
     *     MemberResponse updatedMember = memberService.updateMember(1L, updateRequest);
     *     System.out.println("Miembro actualizado: " + updatedMember.getFullName());
     *     System.out.println("Nuevo peso: " + updatedMember.getWeight() + " kg");
     * } catch (MemberNotFoundException e) {
     *     System.err.println("Miembro no encontrado para actualizar");
     * } catch (DuplicateEmailException e) {
     *     System.err.println("El email ya está en uso por otro miembro");
     * }
     * }</pre>
     *
     * @param id Identificador único del miembro a actualizar. Debe existir en el sistema.
     * @param request Objeto DTO con los campos a actualizar. Solo se procesan campos no nulos.
     *                Puede incluir cualquier combinación de campos actualizables.
     * @return {@link MemberResponse} Información completa del miembro después de la actualización,
     *         con el timestamp 'updatedAt' reflejando el momento de la modificación.
     * @throws com.gym_management.system.exception.MemberNotFoundException 
     *         Si no existe un miembro con el ID especificado.
     * @throws com.gym_management.system.exception.DuplicateEmailException 
     *         Si el nuevo email ya está registrado por otro miembro.
     * @see UpdateMemberRequest
     * @see MemberResponse
     * @since 1.0
     */
    MemberResponse updateMember(Long id, UpdateMemberRequest request);

    /**
     * Elimina un miembro del sistema utilizando borrado lógico (soft delete).
     * 
     * <p>Este método no elimina físicamente el registro de la base de datos, 
     * sino que marca al miembro como inactivo (isActive = false). Esto permite
     * mantener un historial completo para auditorías y reportes.</p>
     * 
     * <p><strong>Ventajas del borrado lógico:</strong></p>
     * <ul>
     *   <li>Preserva datos para auditorías</li>
     *   <li>Permite restaurar miembros accidentalmente eliminados</li>
     *   <li>Mantiene integridad referencial</li>
     *   <li>Facilita reportes históricos</li>
     * </ul>
     * 
     * <p><strong>Nota importante:</strong> Un miembro marcado como inactivo:</p>
     * <ul>
     *   <li>No aparece en búsquedas de miembros activos</li>
     *   <li>No puede realizar nuevas actividades</li>
     *   <li>Conserva su email para evitar re-registros accidentales</li>
     * </ul>
     * 
     * <p><strong>Ejemplo de uso:</strong></p>
     * <pre>{@code
     * Long memberIdToDelete = 5L;
     * 
     * try {
     *     // Verificar que el miembro existe antes de eliminar
     *     MemberResponse member = memberService.getMemberById(memberIdToDelete);
     *     System.out.println("Eliminando miembro: " + member.getFullName());
     *     
     *     memberService.deleteMember(memberIdToDelete);
     *     System.out.println("✅ Miembro marcado como inactivo exitosamente");
     *     
     * } catch (MemberNotFoundException e) {
     *     System.err.println("❌ No se puede eliminar: miembro no encontrado");
     * }
     * }</pre>
     *
     * @param id Identificador único del miembro a eliminar. Debe corresponder a un miembro existente.
     * @throws com.gym_management.system.exception.MemberNotFoundException 
     *         Si no existe un miembro con el ID especificado.
     * @throws IllegalArgumentException Si el ID es null o menor a 1.
     * @see #getMemberById(Long)
     * @since 1.0
     */
    void deleteMember(Long id);

    /**
     * Busca miembros por nombre o apellido utilizando coincidencias parciales.
     * 
     * <p>Este método realiza una búsqueda flexible que permite encontrar miembros
     * cuyo nombre o apellido contengan el término de búsqueda. La búsqueda es
     * case-insensitive y busca en ambos campos simultáneamente.</p>
     * 
     * <p><strong>Características de la búsqueda:</strong></p>
     * <ul>
     *   <li>Case-insensitive (no distingue mayúsculas/minúsculas)</li>
     *   <li>Búsqueda parcial (coincidencias que contengan el término)</li>
     *   <li>Busca en firstName Y lastName</li>
     *   <li>Retorna todos los miembros que coincidan</li>
     * </ul>
     * 
     * <p><strong>Ejemplos de búsqueda:</strong></p>
     * <pre>{@code
     * // Buscar todos los "Juan" (nombre) o "Juanita" (apellido)
     * List<MemberResponse> juans = memberService.searchMembersByName("Juan");
     * 
     * // Buscar por apellido parcial
     * List<MemberResponse> garcias = memberService.searchMembersByName("Garc");
     * 
     * // Buscar con diferentes casos
     * List<MemberResponse> results = memberService.searchMembersByName("PEREZ");
     * // Encuentra "Pérez", "perez", "Perez", etc.
     * 
     * System.out.println("Miembros encontrados: " + results.size());
     * for (MemberResponse member : results) {
     *     System.out.println("- " + member.getFullName() + " (" + member.getEmail() + ")");
     * }
     * }</pre>
     *
     * @param searchTerm Término de búsqueda a buscar en nombres y apellidos. 
     *                   No puede ser null o vacío. Se recomienda al menos 2 caracteres
     *                   para evitar resultados demasiado amplios.
     * @return {@link List}&lt;{@link MemberResponse}&gt; Lista de miembros que coinciden 
     *         con el término de búsqueda. La lista puede estar vacía si no hay coincidencias.
     *         Los resultados incluyen tanto miembros activos como inactivos.
     * @throws IllegalArgumentException Si el término de búsqueda es null, vacío o muy corto.
     * @see MemberResponse
     * @since 1.0
     */
    List<MemberResponse> searchMembersByName(String searchTerm);

    /**
     * Obtiene todos los miembros que están actualmente activos en el sistema.
     * 
     * <p>Este método retorna únicamente los miembros que tienen el estado 
     * {@code isActive = true}, excluyendo aquellos que han sido marcados como 
     * inactivos a través del borrado lógico.</p>
     * 
     * <p><strong>Casos de uso típicos:</strong></p>
     * <ul>
     *   <li>Listados para check-in en el gimnasio</li>
     *   <li>Envío de notificaciones masivas</li>
     *   <li>Reportes de membresía vigente</li>
     *   <li>Análisis de miembros activos vs total</li>
     * </ul>
     * 
     * <p><strong>Ejemplo de uso:</strong></p>
     * <pre>{@code
     * List<MemberResponse> activeMembers = memberService.getActiveMembers();
     * 
     * System.out.println("=== MIEMBROS ACTIVOS ===");
     * System.out.println("Total de miembros activos: " + activeMembers.size());
     * 
     * // Agrupar por género para estadísticas
     * Map<String, Long> byGender = activeMembers.stream()
     *     .collect(Collectors.groupingBy(
     *         MemberResponse::getGender, 
     *         Collectors.counting()));
     * 
     * System.out.println("Hombres: " + byGender.getOrDefault("M", 0L));
     * System.out.println("Mujeres: " + byGender.getOrDefault("F", 0L));
     * }</pre>
     *
     * @return {@link List}&lt;{@link MemberResponse}&gt; Lista de todos los miembros activos.
     *         La lista puede estar vacía si no hay miembros activos en el sistema.
     *         Los miembros se retornan sin un orden específico.
     * @see MemberResponse
     * @see #getMemberStats()
     * @since 1.0
     */
    List<MemberResponse> getActiveMembers();

    /**
     * Obtiene estadísticas generales sobre los miembros del sistema.
     * 
     * <p>Este método proporciona un resumen estadístico que incluye conteos
     * de miembros totales, activos e inactivos. Es útil para dashboards,
     * reportes ejecutivos y monitoreo del crecimiento de la membresía.</p>
     * 
     * <p><strong>Información incluida:</strong></p>
     * <ul>
     *   <li><strong>Total de miembros:</strong> Todos los registros en el sistema</li>
     *   <li><strong>Miembros activos:</strong> Miembros con isActive = true</li>
     *   <li><strong>Miembros inactivos:</strong> Miembros con isActive = false</li>
     * </ul>
     * 
     * <p><strong>Ejemplo de uso:</strong></p>
     * <pre>{@code
     * MemberStats stats = memberService.getMemberStats();
     * 
     * System.out.println("=== ESTADÍSTICAS DE MEMBRESÍA ===");
     * System.out.println("Total de miembros: " + stats.getTotalMembers());
     * System.out.println("Miembros activos: " + stats.getActiveMembers());
     * System.out.println("Miembros inactivos: " + stats.getInactiveMembers());
     * 
     * // Calcular porcentaje de actividad
     * double activePercentage = (stats.getActiveMembers() * 100.0) / stats.getTotalMembers();
     * System.out.printf("Porcentaje de actividad: %.1f%%\n", activePercentage);
     * 
     * // Verificar crecimiento
     * if (stats.getActiveMembers() > stats.getInactiveMembers()) {
     *     System.out.println("✅ Más miembros activos que inactivos - ¡Buen indicador!");
     * }
     * }</pre>
     *
     * @return {@link MemberStats} Objeto con las estadísticas calculadas. 
     *         Nunca retorna null, aunque los conteos pueden ser cero.
     * @see MemberStats
     * @see #getActiveMembers()
     * @since 1.0
     */
    MemberStats getMemberStats();

    /**
     * Clase para encapsular las estadísticas de miembros del gimnasio.
     * 
     * <p>Esta clase inmutable contiene los conteos fundamentales de miembros
     * que permiten generar reportes y dashboards del estado de la membresía.</p>
     * 
     * <p><strong>Campos disponibles:</strong></p>
     * <ul>
     *   <li>{@code totalMembers} - Total de miembros registrados</li>
     *   <li>{@code activeMembers} - Miembros actualmente activos</li>
     *   <li>{@code inactiveMembers} - Miembros marcados como inactivos</li>
     * </ul>
     * 
     * <p><strong>Invariante:</strong> {@code totalMembers = activeMembers + inactiveMembers}</p>
     * 
     * @since 1.0
     * @see #getMemberStats()
     */
    class MemberStats {
        private final long totalMembers;
        private final long activeMembers;
        private final long inactiveMembers;

        /**
         * Constructor para crear una instancia de estadísticas de miembros.
         * 
         * @param totalMembers Número total de miembros registrados (activos + inactivos)
         * @param activeMembers Número de miembros activos (isActive = true)
         * @param inactiveMembers Número de miembros inactivos (isActive = false)
         */
        public MemberStats(long totalMembers, long activeMembers, long inactiveMembers) {
            this.totalMembers = totalMembers;
            this.activeMembers = activeMembers;
            this.inactiveMembers = inactiveMembers;
        }

        /**
         * Obtiene el número total de miembros registrados en el sistema.
         * @return Número total de miembros en el sistema
         */
        public long getTotalMembers() { return totalMembers; }
        
        /**
         * Obtiene el número de miembros activos.
         * @return Número de miembros activos
         */
        public long getActiveMembers() { return activeMembers; }
        
        /**
         * Obtiene el número de miembros inactivos.
         * @return Número de miembros inactivos
         */
        public long getInactiveMembers() { return inactiveMembers; }
    }
} 