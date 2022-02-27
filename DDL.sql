/******* Creacion de procemientos almacenados *******/
use BD2
go
create procedure TR1
    @firstname as nvarchar(max),
    @lastname as nvarchar(max),
    @email as nvarchar(max),
    @password as nvarchar(max),
    @credits as int
as
    begin try
        declare @userId uniqueidentifier = NEWID();
        if exists (select Email from practica1.Usuarios where Email=@email)
            begin
                print 'Correo ya existente'
                insert into practica1.HistoryLog values (current_timestamp,'TR1 fallo')
            end
        else
            begin
                begin tran TR1
                insert into practica1.Usuarios values (@userId,@firstname,@lastname,@email,current_timestamp,@password,current_timestamp,0);
                declare @roleId uniqueidentifier = (select r.id from practica1.Roles as r where r.RoleName='Student');
                insert into practica1.UsuarioRole values (@roleId,@userId,0);
                insert into practica1.ProfileStudent values (@userId,@credits);
                insert into practica1.TFA values (@userId,0,current_timestamp);
                insert into practica1.Notification values (@userId,'Registrado al sistema',current_timestamp);
                print 'TR1 fue exitosa'
                insert into practica1.HistoryLog values (current_timestamp,'TR1 fue exitosa')
                commit
            end

    end try
    begin catch
        rollback tran @userId
        print 'TR1 fallo'
        insert into practica1.HistoryLog values (current_timestamp,'TR1 Fallo')
    end catch
go

create procedure TR2
    @email nvarchar(max),
    @codCourse int
as
    begin try
        begin tran TR2
            declare @userId uniqueidentifier = (select Id from practica1.Usuarios where Email=@email);
            declare @roleId uniqueidentifier = (select r.id from practica1.Roles as r where r.RoleName='Tutor')
            if (select EmailConfirmed from practica1.Usuarios where Email=@email) = 1
                begin
                    if exists(select CodCourse from practica1.Course where CodCourse = @codCourse)
                        begin
                            insert into practica1.UsuarioRole values (@roleId,@userId,0)
                            insert into practica1.TutorProfile values (@userId,'Codigo Random :v');
                            insert into practica1.CourseTutor values (@userId,@codCourse);
                            insert into practica1.Notification values (@userId,'El usuario fue promovido al rol de tutor',current_timestamp);
                            print 'TR2 fue exitoso'
                            insert into practica1.HistoryLog values (current_timestamp,'TR2 fue exitoso')
                        end
                    else
                        begin
                            print 'El curso no existe'
                            insert into practica1.HistoryLog values (current_timestamp,'TR2 fallo')
                        end
                end
            else
                begin
                    print 'El usuario no ha confirmado la cuenta'
                    insert into practica1.HistoryLog values (current_timestamp,'TR2 fallo')
                end
        commit
    end try
    begin catch
        rollback transaction
        insert into practica1.HistoryLog values (current_timestamp,'TR2 fallo')
    end catch
go

create procedure TR3
    @email nvarchar(max),
    @codCourse int
as
    begin try
        begin tran TR3
            if (select EmailConfirmed from practica1.Usuarios where Email=@email) = 1
                begin
                    declare @studentId uniqueidentifier = (select Id from practica1.Usuarios where Email=@email)
                    declare @tutorId uniqueidentifier = (select TutorId from practica1.CourseTutor where CourseCodCourse=@codCourse)
                    declare @creditsStudent int = (select Credits from practica1.ProfileStudent where UserId=@studentId);
                    declare @creditsReq int = (select CreditsRequired from practica1.Course where CodCourse=@codCourse)
                    if (@creditsStudent >= @creditsReq)
                        begin
                            insert into practica1.CourseAssignment values (@studentId,@codCourse);
                            insert into practica1.Notification values (@studentId,'Su registro de asignacion de curso fue exitoso.',current_timestamp);
                            insert into practica1.Notification values (@tutorId,'Se ha asignado un nuevo estudiante al curso.',current_timestamp);
                            print 'TR3 fue exitoso'
                            insert into practica1.HistoryLog values (current_timestamp,'TR3 fue exitosa')
                        end
                    else
                        begin
                            print 'El usuario no cumple con lo creditos necesarios para asignarse al curso'
                            insert into practica1.HistoryLog values (current_timestamp,'TR3 fallo')
                        end
                end
            else
            begin
                print 'El usuario no ha confirmado la cuenta'
                insert into practica1.HistoryLog values (current_timestamp,'TR3 fallo')
            end
        commit
    end try
    begin catch
        rollback transaction
        insert into practica1.HistoryLog values (current_timestamp,'TR3 fallo')
    end catch
go



